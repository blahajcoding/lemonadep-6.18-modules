// SPDX-License-Identifier: GPL-2.0-only
/*
 * Xiaomi's /sys/class/thermal/thermal_message for redwood on 6.12.
 *
 * On 5.4, Xiaomi's patched thermal core registers it, and mi_thermald
 * talks to the thermal policy through its nodes: mostly plain values it
 * writes and reads back, cpu_limits, which caps a CPU's frequency, and
 * screen_state and usb_online, which it watches. 6.12's thermal core
 * doesn't export its class, so borrow it from a cooling device of our own.
 * cpu_limits becomes a cpufreq QoS maximum on the CPU's policy.
 */

#include <linux/atomic.h>
#include <linux/cpufreq.h>
#include <linux/device.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/pm_qos.h>
#include <linux/power_supply.h>
#include <linux/slab.h>
#include <linux/thermal.h>
#include <linux/workqueue.h>

static char *board_sensor = "VIRTUAL-SENSOR";
module_param(board_sensor, charp, 0444);

static struct thermal_cooling_device *cdev;
static struct device *msg_dev;

#define INT_NODE(name)								\
static atomic_t name##_val = ATOMIC_INIT(0);					\
static ssize_t name##_show(struct device *d, struct device_attribute *a,	\
			   char *buf)						\
{										\
	return sysfs_emit(buf, "%d\n", atomic_read(&name##_val));		\
}										\
static ssize_t name##_store(struct device *d, struct device_attribute *a,	\
			    const char *buf, size_t len)			\
{										\
	int v;									\
										\
	if (kstrtoint(buf, 10, &v))						\
		return -EINVAL;							\
	atomic_set(&name##_val, v);						\
	return len;								\
}										\
static DEVICE_ATTR(name, 0664, name##_show, name##_store)

#define STR_NODE(name, mode)							\
static char name##_buf[128];							\
static DEFINE_MUTEX(name##_lock);						\
static ssize_t name##_show(struct device *d, struct device_attribute *a,	\
			   char *buf)						\
{										\
	ssize_t n;								\
										\
	mutex_lock(&name##_lock);						\
	n = sysfs_emit(buf, "%s", name##_buf);					\
	mutex_unlock(&name##_lock);						\
	return n;								\
}										\
static ssize_t name##_store(struct device *d, struct device_attribute *a,	\
			    const char *buf, size_t len)			\
{										\
	mutex_lock(&name##_lock);						\
	strscpy(name##_buf, buf, sizeof(name##_buf));				\
	mutex_unlock(&name##_lock);						\
	return len;								\
}										\
static DEVICE_ATTR(name, mode, name##_show, name##_store)

INT_NODE(sconfig);
INT_NODE(balance_mode);
INT_NODE(temp_state);
INT_NODE(charger_temp);
INT_NODE(modem_limit);
INT_NODE(market_download_limit);
INT_NODE(flash_state);
INT_NODE(wifi_limit);
INT_NODE(poor_modem_limit);
STR_NODE(boost, 0644);
STR_NODE(board_sensor_temp, 0664);
STR_NODE(board_sensor_second_temp, 0664);

static ssize_t board_sensor_show(struct device *d, struct device_attribute *a, char *buf)
{
	return sysfs_emit(buf, "%s", board_sensor);
}
static DEVICE_ATTR(board_sensor, 0444, board_sensor_show, NULL);

/* nothing on 6.12 says when the panel turns off; report it on */
static ssize_t screen_state_show(struct device *d, struct device_attribute *a, char *buf)
{
	return sysfs_emit(buf, "1\n");
}
static DEVICE_ATTR(screen_state, 0444, screen_state_show, NULL);

static atomic_t usb_online = ATOMIC_INIT(0);
static ssize_t usb_online_show(struct device *d, struct device_attribute *a, char *buf)
{
	return sysfs_emit(buf, "%d\n", atomic_read(&usb_online));
}
static DEVICE_ATTR(usb_online, 0444, usb_online_show, NULL);

/*
 * mi_thermald caps the big cores hard as soon as its virtual skin sensor
 * passes 35 C (down to 940 MHz on gold), which made the UI stutter in plain
 * use, often while charging. Its configs are encrypted, so keep its caps
 * from going below these floors instead; 0 leaves its cap as it is. The
 * SoC's own thermal limits and the charging limits are not affected.
 */
static unsigned int gold_limit_floor;
module_param(gold_limit_floor, uint, 0644);
MODULE_PARM_DESC(gold_limit_floor, "Lowest cap mi_thermald may set on the gold CPUs, in kHz");
static unsigned int prime_limit_floor;
module_param(prime_limit_floor, uint, 0644);
MODULE_PARM_DESC(prime_limit_floor, "Lowest cap mi_thermald may set on the prime CPU, in kHz");

/* "cpu<N> <max kHz>": cap the frequency of the policy CPU N belongs to */
static DEFINE_MUTEX(limits_lock);
static struct freq_qos_request limit_req[NR_CPUS];
static struct cpufreq_policy *limit_policy[NR_CPUS];

static ssize_t cpu_limits_show(struct device *d, struct device_attribute *a, char *buf)
{
	return 0;
}

static ssize_t cpu_limits_store(struct device *d, struct device_attribute *a,
				const char *buf, size_t len)
{
	unsigned int cpu, max;
	struct cpufreq_policy *policy;
	int ret = 0;

	if (sscanf(buf, "cpu%u %u", &cpu, &max) != 2 || cpu >= nr_cpu_ids)
		return -EINVAL;
	policy = cpufreq_cpu_get(cpu);
	if (!policy)
		return -ENODEV;
	cpu = policy->cpu;
	if (cpu == 7)
		max = max(max, READ_ONCE(prime_limit_floor));
	else if (cpu >= 4)
		max = max(max, READ_ONCE(gold_limit_floor));
	mutex_lock(&limits_lock);
	if (!limit_policy[cpu]) {
		ret = freq_qos_add_request(&policy->constraints, &limit_req[cpu],
					   FREQ_QOS_MAX, max);
		if (ret >= 0) {
			limit_policy[cpu] = policy;
			policy = NULL;	/* the request keeps the reference */
		}
	} else {
		ret = freq_qos_update_request(&limit_req[cpu], max);
	}
	mutex_unlock(&limits_lock);
	if (policy)
		cpufreq_cpu_put(policy);
	return ret < 0 ? ret : len;
}
static DEVICE_ATTR(cpu_limits, 0664, cpu_limits_show, cpu_limits_store);

static struct attribute *msg_attrs[] = {
	&dev_attr_sconfig.attr,
	&dev_attr_balance_mode.attr,
	&dev_attr_boost.attr,
	&dev_attr_temp_state.attr,
	&dev_attr_cpu_limits.attr,
	&dev_attr_board_sensor.attr,
	&dev_attr_board_sensor_temp.attr,
	&dev_attr_board_sensor_second_temp.attr,
	&dev_attr_charger_temp.attr,
	&dev_attr_modem_limit.attr,
	&dev_attr_market_download_limit.attr,
	&dev_attr_flash_state.attr,
	&dev_attr_wifi_limit.attr,
	&dev_attr_poor_modem_limit.attr,
	&dev_attr_screen_state.attr,
	&dev_attr_usb_online.attr,
	NULL,
};
ATTRIBUTE_GROUPS(msg);

/*
 * Smart charging. Xiaomi's charger firmware takes a thermal level on the
 * battery cooling device, 0 the fastest, and looks the current up itself;
 * mi_thermald steps it from fixed skin temperature tables. Instead keep a
 * charging current budget and move it with where the skin temperature is
 * heading: smooth it, estimate its slope, and cut the budget only while the
 * estimate a minute ahead is over the target. A warm phone that is cooling
 * keeps charging fast, one heating up quickly is slowed before it overshoots.
 *
 * Most of the skin heat comes from the room and from use, not from charging,
 * so the budget never drops below a floor that still charges well unless the
 * battery or the skin is too hot.
 */
static bool smart_charge = true;
module_param(smart_charge, bool, 0644);
MODULE_PARM_DESC(smart_charge, "Pick the charging thermal level from the skin temperature trend");

static int sc_target = 40000;
module_param_named(smart_charge_target, sc_target, int, 0644);
MODULE_PARM_DESC(smart_charge_target, "Skin temperature to charge at, in millidegrees C");

static int sc_low_soc = 20;
module_param_named(smart_charge_low_soc, sc_low_soc, int, 0644);
MODULE_PARM_DESC(smart_charge_low_soc, "Below this charge level the target is raised");

static int sc_low_soc_bonus = 1000;
module_param_named(smart_charge_low_soc_bonus, sc_low_soc_bonus, int, 0644);
MODULE_PARM_DESC(smart_charge_low_soc_bonus, "How far the target is raised at a low charge level, in mC");

static int sc_min_ua = 2700000;
module_param_named(smart_charge_min_ua, sc_min_ua, int, 0644);
MODULE_PARM_DESC(smart_charge_min_ua, "Lowest charging current outside the safety limits, in uA");

static int sc_level;
module_param_named(smart_charge_level, sc_level, int, 0444);
static int sc_budget_ua = INT_MAX;
module_param_named(smart_charge_budget_ua, sc_budget_ua, int, 0444);
static int sc_skin;
module_param_named(smart_charge_skin, sc_skin, int, 0444);
static int sc_slope;
module_param_named(smart_charge_slope, sc_slope, int, 0444);
MODULE_PARM_DESC(smart_charge_slope, "Smoothed skin temperature slope, in mC per minute");

#define SC_PERIOD_MS		5000
#define SC_CUT_GAP		(15 * HZ)
#define SC_RAISE_GAP		(30 * HZ)
#define SC_MAX_UA		12000000

/*
 * Battery current per thermal level, measured on redwood with a 33 W
 * charger: levels 0-7 are above what that charger gives, so those are
 * the DT mitigation table's values.
 */
static const int sc_level_ua[] = {
	10000000, 9500000, 9000000, 8500000, 8000000, 7500000, 7000000, 6500000,
	4800000, 3800000, 3400000, 2700000, 2000000, 1400000, 1000000, 500000,
};

/* The fastest level that stays within @ua */
static int sc_level_for(int ua)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(sc_level_ua); i++)
		if (sc_level_ua[i] <= ua)
			return i;
	return ARRAY_SIZE(sc_level_ua) - 1;
}

static struct power_supply *sc_batt;
static struct thermal_cooling_device *sc_cdev;
static bool sc_applied, sc_valid;
static unsigned long sc_last_up, sc_last_down;
static void sc_work_fn(struct work_struct *work);
static DECLARE_DELAYED_WORK(sc_work, sc_work_fn);

static int sc_match_cdev(struct device *dev, const void *data)
{
	struct thermal_cooling_device *c;

	if (strncmp(dev_name(dev), "cooling_device", 14))
		return 0;
	c = container_of(dev, struct thermal_cooling_device, device);
	return c->type && !strcmp(c->type, "battery");
}

static bool sc_get_devices(void)
{
	struct device *dev;

	if (!sc_batt)
		sc_batt = power_supply_get_by_name("battery");
	if (!sc_cdev && cdev) {
		dev = class_find_device(cdev->device.class, NULL, NULL, sc_match_cdev);
		if (dev)
			sc_cdev = container_of(dev, struct thermal_cooling_device, device);
	}
	return sc_batt && sc_cdev;
}

static void sc_set_level(int level)
{
	unsigned long cur;

	mutex_lock(&sc_cdev->lock);
	level = clamp_t(int, level, 0, (int)sc_cdev->max_state - 1);
	/* Write again when mi_thermald changed it in between */
	if (sc_cdev->ops->get_cur_state(sc_cdev, &cur) || cur != level)
		sc_cdev->ops->set_cur_state(sc_cdev, level);
	mutex_unlock(&sc_cdev->lock);
	sc_level = level;
}

static void sc_release(void)
{
	if (sc_applied && sc_cdev)
		sc_set_level(0);
	sc_applied = false;
	sc_valid = false;
	sc_level = 0;
	sc_budget_ua = INT_MAX;
}

static int sc_batt_prop(enum power_supply_property prop, int *val)
{
	union power_supply_propval v;
	int ret = power_supply_get_property(sc_batt, prop, &v);

	if (!ret)
		*val = v.intval;
	return ret;
}

static int sc_read_skin(int *mc)
{
	char buf[sizeof(board_sensor_temp_buf)];

	mutex_lock(&board_sensor_temp_lock);
	strscpy(buf, board_sensor_temp_buf, sizeof(buf));
	mutex_unlock(&board_sensor_temp_lock);
	return kstrtoint(strim(buf), 10, mc);
}

static void sc_work_fn(struct work_struct *work)
{
	int status, soc, batt_temp, cur_ua, skin, prev, inst, pred, target, err;
	int budget, floor, pct = 0, level;
	unsigned long now = jiffies;

	if (!READ_ONCE(smart_charge) || !atomic_read(&usb_online)) {
		sc_release();
		return;
	}

	if (!sc_get_devices() || sc_batt_prop(POWER_SUPPLY_PROP_STATUS, &status) ||
	    status != POWER_SUPPLY_STATUS_CHARGING ||
	    sc_batt_prop(POWER_SUPPLY_PROP_CAPACITY, &soc) ||
	    sc_batt_prop(POWER_SUPPLY_PROP_TEMP, &batt_temp) ||
	    sc_batt_prop(POWER_SUPPLY_PROP_CURRENT_NOW, &cur_ua) ||
	    sc_read_skin(&skin) || skin < 0 || skin > 80000) {
		sc_release();
		goto out;
	}

	if (!sc_valid) {
		sc_skin = skin;
		sc_slope = 0;
		sc_valid = true;
		sc_budget_ua = SC_MAX_UA;
		sc_last_up = sc_last_down = now - SC_RAISE_GAP;
	} else {
		prev = sc_skin;
		sc_skin += (skin - sc_skin) * 3 / 10;
		inst = (sc_skin - prev) * (60000 / SC_PERIOD_MS);
		sc_slope += (inst - sc_slope) / 4;
	}

	/* Where the skin is a minute from now, against where it should be */
	pred = sc_skin + clamp(sc_slope, -3000, 3000);
	target = READ_ONCE(sc_target);
	if (soc < READ_ONCE(sc_low_soc))
		target += READ_ONCE(sc_low_soc_bonus);
	err = pred - target;

	if (err > 1000)
		pct = -20;
	else if (err > 300)
		pct = -10;
	else if (err < -1500)
		pct = 25;
	else if (err < -700)
		pct = 10;

	budget = sc_budget_ua;
	if (pct < 0 && time_after_eq(now, sc_last_down + SC_CUT_GAP)) {
		/* A budget above what the charger delivers cuts nothing, start from that */
		budget = min(budget, abs(cur_ua));
		budget += budget / 100 * pct;
		sc_last_down = now;
	} else if (pct > 0 && time_after_eq(now, sc_last_up + SC_RAISE_GAP)) {
		budget += max(budget / 100 * pct, 250000);
		sc_last_up = now;
	}

	/* The charger firmware guards the cell too, these keep a margin */
	floor = READ_ONCE(sc_min_ua);
	if (batt_temp >= 450 || skin >= 47000) {
		floor = 0;
		budget = min(budget, 500000);
	} else if (batt_temp >= 430 || skin >= 45000) {
		floor = 0;
		budget = min(budget, 2000000);
	}
	budget = clamp(budget, floor, SC_MAX_UA);
	sc_budget_ua = budget;

	level = sc_level_for(budget);
	sc_set_level(level);
	sc_applied = true;
out:
	queue_delayed_work(system_power_efficient_wq, &sc_work,
			   msecs_to_jiffies(SC_PERIOD_MS));
}

static int usb_changed(struct notifier_block *nb, unsigned long event, void *data)
{
	struct power_supply *psy = data;
	union power_supply_propval val;

	if (strcmp(psy->desc->name, "usb") ||
	    power_supply_get_property(psy, POWER_SUPPLY_PROP_ONLINE, &val))
		return NOTIFY_OK;
	if (atomic_xchg(&usb_online, val.intval) != val.intval && msg_dev)
		sysfs_notify(&msg_dev->kobj, NULL, "usb_online");
	if (val.intval)
		queue_delayed_work(system_power_efficient_wq, &sc_work, 0);
	return NOTIFY_OK;
}
static struct notifier_block usb_nb = { .notifier_call = usb_changed };

/* a cooling device that never cools, only there for its class */
static int dummy_get_max(struct thermal_cooling_device *c, unsigned long *s)
{
	*s = 0;
	return 0;
}
static int dummy_get_cur(struct thermal_cooling_device *c, unsigned long *s)
{
	*s = 0;
	return 0;
}
static int dummy_set_cur(struct thermal_cooling_device *c, unsigned long s)
{
	return 0;
}
static const struct thermal_cooling_device_ops dummy_ops = {
	.get_max_state = dummy_get_max,
	.get_cur_state = dummy_get_cur,
	.set_cur_state = dummy_set_cur,
};

static int __init mi_thermal_init(void)
{
	struct power_supply *usb;
	int ret;

	cdev = thermal_cooling_device_register("mi_thermal_message", NULL, &dummy_ops);
	if (IS_ERR(cdev))
		return PTR_ERR(cdev);
	msg_dev = device_create_with_groups(cdev->device.class, NULL, MKDEV(0, 0),
					    NULL, msg_groups, "thermal_message");
	if (IS_ERR(msg_dev)) {
		ret = PTR_ERR(msg_dev);
		msg_dev = NULL;
		thermal_cooling_device_unregister(cdev);
		return ret;
	}
	ret = power_supply_reg_notifier(&usb_nb);
	if (ret)
		pr_warn("mi_thermal: no usb_online updates: %d\n", ret);
	usb = power_supply_get_by_name("usb");
	if (usb) {
		usb_changed(&usb_nb, 0, usb);
		power_supply_put(usb);
	}
	return 0;
}

static void __exit mi_thermal_exit(void)
{
	int cpu;

	power_supply_unreg_notifier(&usb_nb);
	cancel_delayed_work_sync(&sc_work);
	sc_release();
	if (sc_cdev)
		put_device(&sc_cdev->device);
	if (sc_batt)
		power_supply_put(sc_batt);
	for (cpu = 0; cpu < NR_CPUS; cpu++) {
		if (!limit_policy[cpu])
			continue;
		freq_qos_remove_request(&limit_req[cpu]);
		cpufreq_cpu_put(limit_policy[cpu]);
	}
	device_unregister(msg_dev);
	thermal_cooling_device_unregister(cdev);
}

module_init(mi_thermal_init);
module_exit(mi_thermal_exit);

MODULE_DESCRIPTION("Xiaomi thermal_message nodes for mi_thermald");
MODULE_LICENSE("GPL");
