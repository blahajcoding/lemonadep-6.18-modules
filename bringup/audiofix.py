import re, subprocess

def edit(p, fn):
    s = open(p).read()
    t = fn(s)
    if t == s:
        print("unchanged", p)
    open(p, "w").write(t)

# pinctrl: PIN_CONFIG_LEVEL and gpio .set returning int
def pinctrl(s):
    s = s.replace("PIN_CONFIG_OUTPUT:", "PIN_CONFIG_LEVEL:").replace("PIN_CONFIG_OUTPUT,", "PIN_CONFIG_LEVEL,").replace("PIN_CONFIG_OUTPUT)", "PIN_CONFIG_LEVEL)")
    m = re.search(r"static void (\w+_gpio_set)\(struct gpio_chip \*chip, unsigned( int)? (\w+), int (\w+)\)\n\{(.*?)\n\}\n", s, re.S)
    if m:
        body = m.group(5)
        new = "static int %s(struct gpio_chip *chip, unsigned%s %s, int %s)\n{%s\n\n\treturn 0;\n}\n" % (
            m.group(1), m.group(2) or "", m.group(3), m.group(4), body)
        s = s.replace(m.group(0), new, 1)
        print("gpio set ->int:", m.group(1))
    return s

for p in ["soc/pinctrl-wcd.c", "soc/pinctrl-lpi.c"]:
    edit(p, pinctrl)

def compr(s):
    s = s.replace("int msm_compr_new(struct snd_soc_pcm_runtime *rtd, int num)", "int msm_compr_new(struct snd_soc_pcm_runtime *rtd)")
    s = s.replace("rc = snd_soc_new_compress(rtd, num);", "rc = snd_soc_new_compress(rtd);")
    s = re.sub(r"(static int msm_compr_pointer\([^)]*?)struct snd_compr_tstamp \*", r"\1struct snd_compr_tstamp64 *", s, flags=re.S)
    return s

edit("asoc/msm-compress-q6-v2.c", compr)

for hdr in subprocess.run(["grep", "-rl", "msm_compr_new", "include", "asoc"], capture_output=True, text=True).stdout.split():
    if hdr.endswith(".h"):
        edit(hdr, lambda s: s.replace("int msm_compr_new(struct snd_soc_pcm_runtime *rtd, int num);", "int msm_compr_new(struct snd_soc_pcm_runtime *rtd);"))

def lahaina(s):
    s = s.replace("#include <trace/hooks/sound.h>\n", "")
    s = re.sub(r"\n\s*register_trace_android_vh_snd_pcm_check_no_buffer\(qcom_check_hostless, NULL\);", "", s)
    s = re.sub(r"\n\s*unregister_trace_android_vh_snd_pcm_check_no_buffer\(qcom_check_hostless, NULL\);", "", s)
    return s

edit("asoc/lahaina.c", lahaina)
print("ok")
