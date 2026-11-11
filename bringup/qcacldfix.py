import re, sys
root = sys.argv[1]
p = root + "/core/hdd/src/wlan_hdd_cfg80211.c"
s = open(p).read()

# 6.18 cfg80211 hands these ops a wireless_dev; hdd's handlers still take the
# net_device, so give each one a thin wrapper.
W = {
 "change_station": ("wlan_hdd_change_station", "const u8 *mac, struct station_parameters *params", "mac, params"),
 "add_key": ("wlan_hdd_cfg80211_add_key", "int link_id, u8 key_index, bool pairwise, const u8 *mac_addr, struct key_params *params", "link_id, key_index, pairwise, mac_addr, params"),
 "get_key": ("wlan_hdd_cfg80211_get_key", "int link_id, u8 key_index, bool pairwise, const u8 *mac_addr, void *cookie, void (*callback)(void *cookie, struct key_params *)", "link_id, key_index, pairwise, mac_addr, cookie, callback"),
 "del_key": ("wlan_hdd_cfg80211_del_key", "int link_id, u8 key_index, bool pairwise, const u8 *mac_addr", "link_id, key_index, pairwise, mac_addr"),
 "set_default_mgmt_key": ("wlan_hdd_set_default_mgmt_key", "int link_id, u8 key_index", "link_id, key_index"),
 "set_default_beacon_key": ("wlan_hdd_cfg80211_set_default_beacon_key", "int link_id, u8 key_index", "link_id, key_index"),
 "dump_station": ("wlan_hdd_cfg80211_dump_station", "int idx, u8 *mac, struct station_info *sinfo", "idx, mac, sinfo"),
 "get_station": ("wlan_hdd_cfg80211_get_station", "const u8 *mac, struct station_info *sinfo", "mac, sinfo"),
 "del_station": ("wlan_hdd_cfg80211_del_station", "struct station_del_parameters *params", "params"),
 "add_station": ("wlan_hdd_cfg80211_add_station", "const u8 *mac, struct station_parameters *params", "mac, params"),
}
anchor = "static struct cfg80211_ops wlan_hdd_cfg80211_ops = {"
assert anchor in s and "hdd618_" not in s
wr = ["#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 17, 0)",
      "/* 6.17+ cfg80211 passes a wireless_dev to these ops */"]
for op, (fn, args, call) in W.items():
    guard = op == "set_default_beacon_key"
    if guard:
        wr.append("#if defined (CFG80211_BIGTK_CONFIGURATION_SUPPORT) || \\\n\t    (LINUX_VERSION_CODE >= KERNEL_VERSION(5, 7, 0))")
    wr.append("static int hdd618_%s(struct wiphy *wiphy, struct wireless_dev *wdev,\n\t\t%s)\n{\n\treturn %s(wiphy, wdev->netdev, %s);\n}" % (op, args, fn, call))
    if guard:
        wr.append("#endif")
wr.append("static int hdd618_remain_on_channel(struct wiphy *wiphy, struct wireless_dev *wdev,\n\t\tstruct ieee80211_channel *chan, unsigned int duration, u64 *cookie,\n\t\tconst u8 *rx_addr)\n{\n\treturn wlan_hdd_cfg80211_remain_on_channel(wiphy, wdev, chan, duration, cookie);\n}")
wr.append("#define HDD618(op, fn) hdd618_##op\n#else\n#define HDD618(op, fn) fn\n#endif\n")
s = s.replace(anchor, "\n".join(wr) + "\n" + anchor, 1)
tbl_start = s.index(anchor)
tbl_end = s.index("\n};", tbl_start)
tbl = s[tbl_start:tbl_end]
for op, (fn, _, _) in list(W.items()) + [("remain_on_channel", ("wlan_hdd_cfg80211_remain_on_channel", 0, 0))]:
    new, n = re.subn(r"\.%s = %s," % (op, fn), ".%s = HDD618(%s, %s)," % (op, op, fn), tbl)
    assert n == 1, op
    tbl = new
s = s[:tbl_start] + tbl + s[tbl_end:]
open(p, "w").write(s)

for f, pats in (("core/hdd/src/wlan_hdd_hostapd.c", ["cfg80211_new_sta(dev,", "cfg80211_del_sta(dev,"]),
                ("core/hdd/src/wlan_hdd_main.c", ["cfg80211_del_sta(adapter->dev,"])):
    q = root + "/" + f
    t = open(q).read()
    for pat in pats:
        dev = pat[pat.index("(") + 1:-1]
        assert pat in t, pat
        t = t.replace(pat, pat.replace(dev + ",", "%s->ieee80211_ptr," % dev))
    open(q, "w").write(t)
print("ok")
