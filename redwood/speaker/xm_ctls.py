#!/usr/bin/env python3
# Give mainline aw88261 the control names redwood's vendor mixer paths use
# (Xiaomi's aw882xx driver): aw_dev_<channel>_prof picks the tuning profile
# (Receiver is the earpiece, which is the top speaker) and
# aw_dev_<channel>_switch mutes an amp. Usage: xm_ctls.py <dir with aw88261.[ch]>
import os, sys

d = sys.argv[1]
c = os.path.join(d, "aw88261.c")
h = os.path.join(d, "aw88261.h")


def sub(path, old, new):
    s = open(path).read()
    if s.count(old) != 1:
        sys.exit("xm_ctls: no unique match in %s for %r" % (path, old[:60]))
    open(path, "w").write(s.replace(old, new))


sub(h, "\tbool phase_sync;\n};", "\tbool phase_sync;\n\tbool xm_off;\n};")

# the PLL locks as the I2S clock starts; polling it is not an error
sub(c, """		dev_err(aw_dev->dev, "check pll lock fail,reg_val:0x%04x", reg_val);""",
    """		dev_dbg(aw_dev->dev, "check pll lock fail,reg_val:0x%04x", reg_val);""")
sub(c, """			dev_err(aw_dev->dev, "mode1 iis signal check error");""",
    """			dev_dbg(aw_dev->dev, "mode1 iis signal check error");""")

# an amp switched off stays muted across restarts
sub(c, """			dev_info(aw88261->aw_pa->dev, "start success\\n");
			break;""", """			dev_info(aw88261->aw_pa->dev, "start success\\n");
			if (aw88261->xm_off)
				aw88261_dev_mute(aw88261->aw_pa, true);
			break;""")

sub(c, "static int aw88261_codec_probe(struct snd_soc_component *component)\n{",
    """static const char * const aw88261_xm_switch_text[] = { "Disable", "Enable" };
static const struct soc_enum aw88261_xm_switch_enum =
	SOC_ENUM_SINGLE_EXT(ARRAY_SIZE(aw88261_xm_switch_text), aw88261_xm_switch_text);

static int aw88261_xm_switch_get(struct snd_kcontrol *kcontrol,
		struct snd_ctl_elem_value *ucontrol)
{
	struct snd_soc_component *codec = snd_soc_kcontrol_component(kcontrol);
	struct aw88261 *aw88261 = snd_soc_component_get_drvdata(codec);

	ucontrol->value.enumerated.item[0] = !aw88261->xm_off;

	return 0;
}

static int aw88261_xm_switch_put(struct snd_kcontrol *kcontrol,
		struct snd_ctl_elem_value *ucontrol)
{
	struct snd_soc_component *codec = snd_soc_kcontrol_component(kcontrol);
	struct aw88261 *aw88261 = snd_soc_component_get_drvdata(codec);
	bool off = !ucontrol->value.enumerated.item[0];

	if (off == aw88261->xm_off)
		return 0;

	mutex_lock(&aw88261->lock);
	aw88261->xm_off = off;
	if (aw88261->aw_pa->status == AW88261_DEV_PW_ON)
		aw88261_dev_mute(aw88261->aw_pa, off);
	mutex_unlock(&aw88261->lock);

	return 1;
}

/*
 * The earpiece (Receiver profile) follows the call volume: q6voice tells
 * every listener the RX volume step, and the Receiver attenuation grows
 * by receiver_step_att per step. Found with symbol_get(), so the amp still
 * loads without q6voice.
 */
int voc_register_rx_vol_notifier(struct notifier_block *nb);
int voc_unregister_rx_vol_notifier(struct notifier_block *nb);

struct aw88261_xm_nb {
	struct notifier_block nb;
	struct aw88261 *aw88261;
};

static int aw88261_xm_vol_event(struct notifier_block *nb, unsigned long step,
		void *data)
{
	struct aw88261_xm_nb *x = container_of(nb, struct aw88261_xm_nb, nb);
	struct aw88261 *aw88261 = x->aw88261;
	struct aw_device *aw_dev = aw88261->aw_pa;
	struct aw_volume_desc *vd = &aw_dev->volume_desc;
	unsigned int att;

	WRITE_ONCE(xm_voice_rx_step, step);

	mutex_lock(&aw88261->lock);
	if (aw_dev->status == AW88261_DEV_PW_ON) {
		att = aw88261_xm_att(aw_dev, vd->init_volume);
		if (att != vd->init_volume) {
			vd->init_volume = att;
			aw88261_dev_set_volume(aw_dev, vd->ctl_volume);
		}
	}
	mutex_unlock(&aw88261->lock);

	return NOTIFY_OK;
}

static void aw88261_xm_vol_unregister(void *data)
{
	struct aw88261_xm_nb *x = data;
	int (*unreg)(struct notifier_block *nb);

	unreg = symbol_get(voc_unregister_rx_vol_notifier);
	if (unreg) {
		unreg(&x->nb);
		symbol_put(voc_unregister_rx_vol_notifier);
	}
	symbol_put(voc_register_rx_vol_notifier);
}

static void aw88261_xm_vol_register(struct snd_soc_component *component)
{
	struct aw88261 *aw88261 = snd_soc_component_get_drvdata(component);
	int (*reg)(struct notifier_block *nb);
	struct aw88261_xm_nb *x;

	reg = symbol_get(voc_register_rx_vol_notifier);
	if (!reg) {
		dev_info(component->dev, "no q6voice, earpiece volume stays fixed\\n");
		return;
	}
	x = devm_kzalloc(component->dev, sizeof(*x), GFP_KERNEL);
	if (!x) {
		symbol_put(voc_register_rx_vol_notifier);
		return;
	}
	x->aw88261 = aw88261;
	x->nb.notifier_call = aw88261_xm_vol_event;
	if (reg(&x->nb)) {
		symbol_put(voc_register_rx_vol_notifier);
		return;
	}
	devm_add_action_or_reset(component->dev, aw88261_xm_vol_unregister, x);
}

/*
 * Card-level controls, so the component's name prefix (AW_R, AW_L) isn't
 * added: the vendor mixer paths ask for exactly these names.
 */
static int aw88261_add_xm_controls(struct snd_soc_component *component)
{
	struct aw88261 *aw88261 = snd_soc_component_get_drvdata(component);
	struct snd_card *card = component->card->snd_card;
	unsigned int ch = aw88261->aw_pa->channel;
	struct snd_kcontrol_new prof = AW88261_PROFILE_EXT(NULL, aw88261_profile_info,
			aw88261_profile_get, aw88261_profile_set);
	struct snd_kcontrol_new sw = SOC_ENUM_EXT(NULL, aw88261_xm_switch_enum,
			aw88261_xm_switch_get, aw88261_xm_switch_put);
	int ret;

	prof.name = devm_kasprintf(component->dev, GFP_KERNEL, "aw_dev_%u_prof", ch);
	sw.name = devm_kasprintf(component->dev, GFP_KERNEL, "aw_dev_%u_switch", ch);
	if (!prof.name || !sw.name)
		return -ENOMEM;

	ret = snd_ctl_add(card, snd_ctl_new1(&prof, component));
	if (ret)
		return ret;

	ret = snd_ctl_add(card, snd_ctl_new1(&sw, component));
	if (ret)
		return ret;

	aw88261_xm_vol_register(component);
	return 0;
}

static int aw88261_codec_probe(struct snd_soc_component *component)
{""")

sub(c, """	ret = snd_soc_add_component_controls(component, aw88261_controls,
							ARRAY_SIZE(aw88261_controls));

	return ret;
}""", """	ret = snd_soc_add_component_controls(component, aw88261_controls,
							ARRAY_SIZE(aw88261_controls));
	if (ret)
		return ret;

	return aw88261_add_xm_controls(component);
}""")
# The vendor tuning leaves 2.1 dB of attenuation on the speakers (Music) and
# 7 dB on the earpiece (Receiver). Let a module parameter set it per profile,
# in the amp's 1/8 dB steps; -1 keeps the ACF value.
sub(c, "static void aw88261_dev_set_volume(struct aw_device *aw_dev, unsigned int value)\n{",
    """static int music_att;
module_param(music_att, int, 0644);
MODULE_PARM_DESC(music_att, "Music profile attenuation in 1/8 dB, -1 keeps the ACF value");

static int receiver_att = 24;
module_param(receiver_att, int, 0644);
MODULE_PARM_DESC(receiver_att, "Receiver profile attenuation in 1/8 dB, -1 keeps the ACF value");

static int receiver_step_att = 32;
module_param(receiver_step_att, int, 0644);
MODULE_PARM_DESC(receiver_step_att, "Earpiece attenuation per call volume step in 1/8 dB, 0 ignores the call volume");

/* the call's RX volume step from q6voice, 0 is the loudest */
static unsigned int xm_voice_rx_step;

static unsigned int aw88261_xm_att(struct aw_device *aw_dev, unsigned int acf)
{
	struct aw_prof_info *info = &aw_dev->prof_info;
	const char *name = info->prof_name_list[info->prof_desc[aw_dev->prof_index].id];
	int att = -1;

	if (!strcmp(name, "Music"))
		att = music_att;
	else if (!strcmp(name, "Receiver")) {
		att = receiver_att;
		if (att >= 0 && receiver_step_att > 0)
			att = min_t(int, att + READ_ONCE(xm_voice_rx_step) *
				    receiver_step_att, AW88261_MUTE_VOL - 1);
	}

	if (att < 0 || att >= AW88261_MUTE_VOL)
		return acf;

	return att;
}

static void aw88261_dev_set_volume(struct aw_device *aw_dev, unsigned int value)
{""")

sub(c, """			aw_dev->volume_desc.init_volume =
				REG_VAL_TO_DB(read_vol);""", """			aw_dev->volume_desc.init_volume =
				aw88261_xm_att(aw_dev, REG_VAL_TO_DB(read_vol));""")

print("xm_ctls: aw_dev_<ch>_prof, aw_dev_<ch>_switch and the profile attenuation added")
