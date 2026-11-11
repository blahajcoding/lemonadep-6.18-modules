#!/usr/bin/env python3
"""Apply the mechanical 6.12 -> 6.18 API renames to every .c/.h under the given directories."""
import os, re, sys

def files(roots):
    for root in roots:
        for d, _, fs in os.walk(root):
            for f in fs:
                if f.endswith((".c", ".h")):
                    yield os.path.join(d, f)

def ida(s):
    def get(m):
        i, start, end, gfp = [x.strip() for x in m.group(1, 2, 3, 4)]
        if end in ("0", "0U", "0u"):
            return f"ida_alloc_min({i}, {start}, {gfp})"
        return f"ida_alloc_range({i}, {start}, ({end}) - 1, {gfp})"
    s = re.sub(r"ida_simple_get\(\s*([^,]+),\s*([^,]+),\s*([^,]+),\s*([^)]+)\)", get, s)
    return re.sub(r"ida_simple_remove\(", "ida_free(", s)

def hrt(s):
    for m in list(re.finditer(r"hrtimer_init\(\s*([^,]+?)\s*,\s*([^,]+?)\s*,\s*([^)]+?)\s*\);", s)):
        tmr = m.group(1)
        acc = tmr[1:] + ".function" if tmr.startswith("&") else tmr + "->function"
        rest = s[m.end():m.end() + 800]
        fm = re.search(re.escape(acc) + r"\s*=\s*([^;]+);", rest)
        if not fm:
            print("  hrtimer_init left:", m.group(0))
            continue
        s = s.replace(m.group(0), f"hrtimer_setup({tmr}, {fm.group(1).strip()}, {m.group(2)}, {m.group(3)});", 1)
        s = s.replace(fm.group(0), "", 1)
    return s

def fix(s):
    s = re.sub(r"\.remove_new(\s*)=", r".remove\1=", s)
    s = re.sub(r"\bfrom_timer\(", "timer_container_of(", s)
    s = re.sub(r"\bdel_timer_sync\(", "timer_delete_sync(", s)
    s = re.sub(r"\bdel_timer\(", "timer_delete(", s)
    s = re.sub(r"\bnth_page\(\s*([^,]+?)\s*,\s*([^)]+?)\s*\)", r"((\1) + (\2))", s)
    s = re.sub(r"MODULE_IMPORT_NS\(([A-Za-z_][A-Za-z0-9_]*)\)", r'MODULE_IMPORT_NS("\1")', s)
    s = re.sub(r"(EXPORT_SYMBOL_NS(?:_GPL)?)\(([^,]+),\s*([A-Za-z_][A-Za-z0-9_]*)\)", r'\1(\2, "\3")', s)
    s = ida(s)
    s = hrt(s)
    # bin_attribute read/write callbacks became const
    s = re.sub(r"(\bssize_t\s+\w+\s*\(\s*struct file\s*\*\s*\w*\s*,\s*struct kobject\s*\*\s*\w*\s*,\s*)struct bin_attribute\s*\*",
               r"\1const struct bin_attribute *", s)
    return s

n = 0
for f in files(sys.argv[1:]):
    try:
        s = open(f, errors="replace").read()
    except OSError:
        continue
    t = fix(s)
    if t != s:
        open(f, "w").write(t)
        n += 1
print("files changed:", n)
