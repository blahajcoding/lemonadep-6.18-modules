#!/usr/bin/env python3
"""Resolve LINUX_VERSION_CODE / KERNEL_VERSION() preprocessor conditionals for
one kernel version, keeping every other conditional untouched.

Usage: lvc618.py [--version 6.18.33] FILE...   (edits files in place)
"""
import re
import sys

UNKNOWN = object()


def kv(a, b, c):
    return (a << 16) + (b << 8) + min(c, 255)


def strip_comments(s):
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    return re.sub(r"//.*", "", s)


TOKEN = re.compile(r"\s*(KERNEL_VERSION\s*\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)|LINUX_VERSION_CODE|"
                   r"defined\s*\(\s*\w+\s*\)|defined\s+\w+|0[xX][0-9a-fA-F]+[uUlL]*|\d+[uUlL]*|\w+|"
                   r"&&|\|\||==|!=|<=|>=|<<|>>|[()!<>+\-*/%&|^~?:])")


class Unknown(Exception):
    pass


def tokenize(expr, lvc):
    out = []
    pos = 0
    expr = expr.strip()
    while pos < len(expr):
        m = TOKEN.match(expr, pos)
        if not m:
            raise Unknown(expr[pos:])
        t = m.group(1)
        pos = m.end()
        if t.startswith("KERNEL_VERSION"):
            a, b, c = map(int, re.findall(r"\d+", t))
            out.append(("num", kv(a, b, c)))
        elif t == "LINUX_VERSION_CODE":
            out.append(("num", lvc))
        elif re.fullmatch(r"0[xX][0-9a-fA-F]+[uUlL]*", t):
            out.append(("num", int(t.rstrip("uUlL"), 16)))
        elif re.fullmatch(r"\d+[uUlL]*", t):
            out.append(("num", int(t.rstrip("uUlL"))))
        elif t.startswith("defined") or re.fullmatch(r"\w+", t):
            out.append(("unk", t))
        else:
            out.append(("op", t))
        while pos < len(expr) and expr[pos].isspace():
            pos += 1
    return out


class Parser:
    """Three-valued evaluator: values are ints or UNKNOWN."""

    def __init__(self, toks):
        self.t = toks
        self.i = 0

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else (None, None)

    def take(self, op=None):
        tok = self.peek()
        if op is not None and tok != ("op", op):
            raise Unknown(f"expected {op}")
        self.i += 1
        return tok

    def parse(self):
        v = self.ternary()
        if self.i != len(self.t):
            raise Unknown("trailing")
        return v

    def ternary(self):
        c = self.lor()
        if self.peek() == ("op", "?"):
            self.take()
            a = self.ternary()
            self.take(":")
            b = self.ternary()
            if c is UNKNOWN:
                return UNKNOWN
            return a if c else b
        return c

    def lor(self):
        v = self.land()
        while self.peek() == ("op", "||"):
            self.take()
            w = self.land()
            if v is not UNKNOWN and v:
                v = 1
            elif w is not UNKNOWN and w:
                v = 1
            elif v is UNKNOWN or w is UNKNOWN:
                v = UNKNOWN
            else:
                v = 0
        return v

    def land(self):
        v = self.cmp()
        while self.peek() == ("op", "&&"):
            self.take()
            w = self.cmp()
            if v is not UNKNOWN and not v:
                v = 0
            elif w is not UNKNOWN and not w:
                v = 0
            elif v is UNKNOWN or w is UNKNOWN:
                v = UNKNOWN
            else:
                v = 1
        return v

    OPS = {"==": lambda a, b: int(a == b), "!=": lambda a, b: int(a != b),
           "<": lambda a, b: int(a < b), ">": lambda a, b: int(a > b),
           "<=": lambda a, b: int(a <= b), ">=": lambda a, b: int(a >= b)}

    def cmp(self):
        v = self.add()
        while self.peek()[0] == "op" and self.peek()[1] in self.OPS:
            op = self.take()[1]
            w = self.add()
            v = UNKNOWN if UNKNOWN in (v, w) else self.OPS[op](v, w)
        return v

    def add(self):
        v = self.unary()
        while self.peek()[0] == "op" and self.peek()[1] in ("+", "-", "<<", ">>", "&", "|", "^"):
            op = self.take()[1]
            w = self.unary()
            if UNKNOWN in (v, w):
                v = UNKNOWN
            else:
                v = {"+": v + w, "-": v - w, "<<": v << w, ">>": v >> w,
                     "&": v & w, "|": v | w, "^": v ^ w}[op]
        return v

    def unary(self):
        tok = self.peek()
        if tok == ("op", "!"):
            self.take()
            v = self.unary()
            return UNKNOWN if v is UNKNOWN else int(not v)
        if tok == ("op", "("):
            self.take()
            v = self.ternary()
            self.take(")")
            return v
        if tok[0] == "num":
            self.take()
            return tok[1]
        if tok[0] == "unk":
            self.take()
            return UNKNOWN
        raise Unknown(f"bad token {tok}")


def evaluate(expr, lvc):
    if "LINUX_VERSION_CODE" not in expr and "KERNEL_VERSION" not in expr:
        return UNKNOWN
    try:
        return Parser(tokenize(strip_comments(expr), lvc)).parse()
    except Unknown:
        return UNKNOWN


DIRECTIVE = re.compile(r"^\s*#\s*(if|ifdef|ifndef|elif|else|endif)\b(.*)$", re.S)


def logical_lines(text):
    """Split into logical lines (joining backslash continuations), keeping raw text."""
    raw = text.split("\n")
    out = []
    i = 0
    while i < len(raw):
        parts = [raw[i]]
        while parts[-1].endswith("\\") and i + 1 < len(raw):
            i += 1
            parts.append(raw[i])
        out.append("\n".join(parts))
        i += 1
    return out


def parse_block(lines, i, lvc):
    """Parse until an #elif/#else/#endif at this level. Returns (items, i)."""
    items = []
    while i < len(lines):
        m = DIRECTIVE.match(lines[i])
        if not m:
            items.append(("text", lines[i]))
            i += 1
            continue
        kind = m.group(1)
        if kind in ("elif", "else", "endif"):
            return items, i
        # start of a group
        branches = []
        cur_line = lines[i]
        cur_kind = kind
        i += 1
        while True:
            body, i = parse_block(lines, i, lvc)
            branches.append((cur_kind, cur_line, body))
            if i >= len(lines):
                raise ValueError("unterminated #if")
            m2 = DIRECTIVE.match(lines[i])
            k2 = m2.group(1)
            if k2 == "endif":
                items.append(("group", branches, lines[i]))
                i += 1
                break
            cur_kind, cur_line = k2, lines[i]
            i += 1
    return items, i


def split_top(expr, op):
    parts, depth, cur, i = [], 0, "", 0
    while i < len(expr):
        ch = expr[i]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if depth == 0 and expr.startswith(op, i):
            parts.append(cur)
            cur = ""
            i += len(op)
            continue
        cur += ch
        i += 1
    parts.append(cur)
    return parts


def simplify(expr, lvc):
    """For a top-level pure && or || chain, drop the version terms that cannot
    change the result. Returns a new expression or None."""
    e = strip_comments(expr.replace("\\\n", " ")).strip()
    for op, neutral in (("&&", 1), ("||", 0)):
        parts = split_top(e, op)
        if len(parts) < 2:
            continue
        other = "||" if op == "&&" else "&&"
        if any(len(split_top(p, other)) > 1 for p in parts):
            return None
        keep = []
        for p in parts:
            v = evaluate(p, lvc)
            if v is UNKNOWN:
                if "LINUX_VERSION_CODE" in p or "KERNEL_VERSION" in p:
                    return None
                keep.append(p.strip())
            elif bool(v) != bool(neutral):
                return None
        if len(keep) == len(parts) or not keep:
            return None
        return f" {op} ".join(keep)
    return None


def cond_value(kind, line, lvc):
    if kind == "else":
        return 1
    if kind in ("ifdef", "ifndef"):
        return UNKNOWN
    expr = DIRECTIVE.match(line).group(2)
    expr = expr.replace("\\\n", " ")
    return evaluate(expr, lvc)


KEEP_LINES = False


def blank(text_or_items, out):
    """Keep line numbers stable: emit an empty line per removed raw line."""
    if not KEEP_LINES:
        return
    if isinstance(text_or_items, str):
        out.extend([""] * (text_or_items.count("\n") + 1))
        return
    for it in text_or_items:
        if it[0] == "text":
            blank(it[1], out)
        else:
            for kind, line, body in it[1]:
                blank(line, out)
                blank(body, out)
            blank(it[2], out)


def put(out, line, orig):
    """Emit a (possibly rewritten) directive in place of orig, padding to the
    same number of physical lines when KEEP_LINES is set."""
    out.append(line)
    if KEEP_LINES:
        out.extend([""] * (orig.count("\n") - line.count("\n")))


def emit(items, lvc, out, stats):
    squeeze = False
    for it in items:
        if it[0] == "text":
            if squeeze and not KEEP_LINES and it[1].strip() == "" and out and out[-1].strip() == "":
                squeeze = False
                continue
            squeeze = False
            out.append(it[1])
            continue
        before = len(out)
        _, branches, endif = it
        # Decide each branch: "drop", "keep" (unknown) or "take" (first true).
        plan = []
        taken = False
        for kind, line, body in branches:
            if taken:
                plan.append("drop")
                continue
            v = cond_value(kind, line, lvc)
            if v is UNKNOWN:
                plan.append("keep")
            elif v:
                plan.append("take")
                taken = True
            else:
                plan.append("drop")
        kept = [i for i, p in enumerate(plan) if p == "keep"]
        take = next((i for i, p in enumerate(plan) if p == "take"), None)
        changed = "drop" in plan or take is not None

        if not kept:
            # The whole group resolves: keep only the taken body, unwrapped.
            for i, (kind, line, body) in enumerate(branches):
                blank(line, out)
                if i == take:
                    emit(body, lvc, out, stats)
                else:
                    blank(body, out)
            blank(endif, out)
            stats["groups"] += 1
            squeeze = len(out) == before
            continue

        first = True
        for i, (kind, line, body) in enumerate(branches):
            if plan[i] == "drop":
                blank(line, out)
                blank(body, out)
                continue
            new = line
            if plan[i] == "take":
                new = "#else"
                if kind == "else":
                    new = line
            elif kind in ("if", "elif"):
                simple = simplify(DIRECTIVE.match(line).group(2), lvc)
                if simple is not None:
                    new = re.match(r"^\s*#\s*\w+", line).group(0) + " " + simple
                    changed = True
            if first and kind == "elif":
                new = re.sub(r"^(\s*#\s*)elif", r"\1if", new, count=1)
            put(out, new, line)
            emit(body, lvc, out, stats)
            first = False
        out.append(endif)
        if changed:
            stats["groups"] += 1


def process(path, lvc):
    with open(path, encoding="utf-8", errors="surrogateescape") as f:
        text = f.read()
    if "LINUX_VERSION_CODE" not in text and "KERNEL_VERSION" not in text:
        return None
    lines = logical_lines(text)
    try:
        items, i = parse_block(lines, 0, lvc)
    except ValueError:
        return "unbalanced"
    if i != len(lines):
        return "unbalanced"
    stats = {"groups": 0, "dropped": 0, "taken": 0}
    out = []
    emit(items, lvc, out, stats)
    new = "\n".join(out)
    if new != text:
        with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
            f.write(new)
        return stats
    return None


def main():
    args = sys.argv[1:]
    ver = "6.18.33"
    global KEEP_LINES
    if args[:1] == ["--keep-lines"]:
        KEEP_LINES = True
        args = args[1:]
    if args[:1] == ["--version"]:
        ver = args[1]
        args = args[2:]
    a, b, c = map(int, ver.split("."))
    lvc = kv(a, b, c)
    total = {"files": 0, "groups": 0}
    for p in args:
        r = process(p, lvc)
        if r == "unbalanced":
            print(f"skip (unbalanced): {p}", file=sys.stderr)
        elif r:
            total["files"] += 1
            total["groups"] += r["groups"]
    print(f"files changed {total['files']}, conditionals resolved {total['groups']}")


if __name__ == "__main__":
    main()
