import re, sys

# 6.18 dropped snd_soc_dai_link.dpcm_playback/dpcm_capture: a link is
# bidirectional unless playback_only or capture_only says otherwise.
for p in sys.argv[1:]:
    s = open(p).read()
    out, i, n = [], 0, 0
    # walk every brace-delimited initializer that mentions dpcm_
    for m in re.finditer(r"\{(?:[^{}]|\{[^{}]*\})*\}", s):
        if ".dpcm_" not in m.group(0):
            continue
        blk = m.group(0)
        pb = re.search(r"\.dpcm_playback\s*=\s*1", blk) is not None
        cp = re.search(r"\.dpcm_capture\s*=\s*1", blk) is not None
        nb = re.sub(r"\n[ \t]*\.dpcm_(?:playback|capture)\s*=\s*\d+,?[^\n]*", "", blk)
        if pb and not cp:
            nb = nb.replace("{", "{\n\t\t.playback_only = 1,", 1)
        elif cp and not pb:
            nb = nb.replace("{", "{\n\t\t.capture_only = 1,", 1)
        out.append(s[i:m.start()])
        out.append(nb)
        i = m.end()
        n += 1
    out.append(s[i:])
    t = "".join(out)
    open(p, "w").write(t)
    print(p, "links:", n, "left:", len(re.findall(r"\.dpcm_(playback|capture)", t)))
