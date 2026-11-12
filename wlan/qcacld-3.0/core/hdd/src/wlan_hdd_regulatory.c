/*
 * Copyright (c) 2014-2021 The Linux Foundation. All rights reserved.
 * Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
 *
 * Permission to use, copy, modify, and/or distribute this software for
 * any purpose with or without fee is hereby granted, provided that the
 * above copyright notice and this permission notice appear in all
 * copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
 * DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

/**
 * DOC: wlan_hdd_regulatory.c
 *
 * hdd regulatory implementation
 */

#include "qdf_types.h"
#include "qdf_trace.h"
#include "wlan_hdd_main.h"
#include <wlan_osif_priv.h>
#include "wlan_hdd_regulatory.h"
#include <wlan_reg_ucfg_api.h>
#include "cds_regdomain.h"
#include "cds_utils.h"
#include "pld_common.h"
#include <net/cfg80211.h>
#include "wlan_policy_mgr_ucfg.h"
#include "sap_api.h"
#include "wlan_hdd_hostapd.h"
#include "osif_psoc_sync.h"

#define REG_RULE_2412_2462    REG_RULE(2412-10, 2462+10, 40, 0, 20, 0)

#define REG_RULE_2467_2472    REG_RULE(2467-10, 2472+10, 40, 0, 20, \
		NL80211_RRF_PASSIVE_SCAN | NL80211_RRF_NO_IBSS)

#define REG_RULE_2484         REG_RULE(2484-10, 2484+10, 20, 0, 20, \
		NL80211_RRF_PASSIVE_SCAN | NL80211_RRF_NO_IBSS | \
				       NL80211_RRF_NO_OFDM)

#define REG_RULE_5180_5320    REG_RULE(5180-10, 5320+10, 160, 0, 20, \
		NL80211_RRF_PASSIVE_SCAN | NL80211_RRF_NO_IBSS)

#define REG_RULE_5500_5720    REG_RULE(5500-10, 5720+10, 160, 0, 20, \
		NL80211_RRF_PASSIVE_SCAN | NL80211_RRF_NO_IBSS)

#define REG_RULE_5745_5925    REG_RULE(5745-10, 5925+10, 80, 0, 20, \
		NL80211_RRF_PASSIVE_SCAN | NL80211_RRF_NO_IBSS)

static bool init_by_driver;
static bool init_by_reg_core;

struct regulatory_channel reg_channels[NUM_CHANNELS];

static const struct ieee80211_regdomain
hdd_world_regrules_60_61_62 = {
	.n_reg_rules = 6,
	.alpha2 =  "00",
	.reg_rules = {
		REG_RULE_2412_2462,
		REG_RULE_2467_2472,
		REG_RULE_2484,
		REG_RULE_5180_5320,
		REG_RULE_5500_5720,
		REG_RULE_5745_5925,
	}
};

static const struct ieee80211_regdomain
hdd_world_regrules_63_65 = {
	.n_reg_rules = 4,
	.alpha2 =  "00",
	.reg_rules = {
		REG_RULE_2412_2462,
		REG_RULE_2467_2472,
		REG_RULE_5180_5320,
		REG_RULE_5745_5925,
	}
};

static const struct ieee80211_regdomain
hdd_world_regrules_64 = {
	.n_reg_rules = 3,
	.alpha2 =  "00",
	.reg_rules = {
		REG_RULE_2412_2462,
		REG_RULE_5180_5320,
		REG_RULE_5745_5925,
	}
};

static const struct ieee80211_regdomain
hdd_world_regrules_66_69 = {
	.n_reg_rules = 4,
	.alpha2 =  "00",
	.reg_rules = {
		REG_RULE_2412_2462,
		REG_RULE_5180_5320,
		REG_RULE_5500_5720,
		REG_RULE_5745_5925,
	}
};

static const struct ieee80211_regdomain
hdd_world_regrules_67_68_6A_6C = {
	.n_reg_rules = 5,
	.alpha2 =  "00",
	.reg_rules = {
		REG_RULE_2412_2462,
		REG_RULE_2467_2472,
		REG_RULE_5180_5320,
		REG_RULE_5500_5720,
		REG_RULE_5745_5925,
	}
};

#define COUNTRY_CHANGE_WORK_RESCHED_WAIT_TIME 30
/**
 * hdd_get_world_regrules() - get the appropriate world regrules
 * @reg: regulatory data
 *
 * Return: regulatory rules ptr
 */

/**
 * hdd_reset_global_reg_params - Reset global static reg params
 *
 * This function is helpful in static driver to reset
 * the global params.
 *
 * Return: void
 */
void hdd_reset_global_reg_params(void)
{
	init_by_driver = false;
	init_by_reg_core = false;
}

/**
 * hdd_update_coex_unsafe_chan_nb_user_prefer() - update coex unsafe
 * nb prefer framework
 * @hdd_ctx: hdd context
 * @config_vars: reg config
 *
 * Return: void
 */
#ifdef FEATURE_WLAN_CH_AVOID_EXT
static inline
void hdd_update_coex_unsafe_chan_nb_user_prefer(
		struct hdd_context *hdd_ctx,
		struct reg_config_vars *config_vars)
{
	config_vars->coex_unsafe_chan_nb_user_prefer =
		ucfg_mlme_get_coex_unsafe_chan_nb_user_prefer(
		hdd_ctx->psoc);
}

static inline
void hdd_update_coex_unsafe_chan_reg_disable(
		struct hdd_context *hdd_ctx,
		struct reg_config_vars *config_vars)
{
	config_vars->coex_unsafe_chan_reg_disable =
		ucfg_mlme_get_coex_unsafe_chan_reg_disable(
		hdd_ctx->psoc);
}
#else
static inline
void hdd_update_coex_unsafe_chan_nb_user_prefer(
		struct hdd_context *hdd_ctx,
		struct reg_config_vars *config_vars)
{
}

static inline
void hdd_update_coex_unsafe_chan_reg_disable(
		struct hdd_context *hdd_ctx,
		struct reg_config_vars *config_vars)
{
}
#endif

static void reg_program_config_vars(struct hdd_context *hdd_ctx,
				    struct reg_config_vars *config_vars)
{
	uint8_t indoor_chnl_marking = 0;
	uint32_t band_capability = 0, scan_11d_interval = 0;
	bool indoor_chan_enabled = false;
	uint32_t restart_beaconing = 0;
	uint8_t enable_srd_chan;
	bool enable_5dot9_ghz_chan;
	QDF_STATUS status;
	bool country_priority = 0;
	bool value = false;
	bool enable_dfs_scan = true;

	status = ucfg_mlme_get_band_capability(hdd_ctx->psoc, &band_capability);
	if (QDF_IS_STATUS_ERROR(status))
		hdd_err("Failed to get MLME band cap, defaulting to BAND_ALL");

	status = ucfg_policy_mgr_get_indoor_chnl_marking(hdd_ctx->psoc,
							 &indoor_chnl_marking);
	if (QDF_STATUS_SUCCESS != status)
		hdd_err("can't get indoor channel marking, using default");

	status = ucfg_mlme_is_11d_enabled(hdd_ctx->psoc, &value);
	if (!QDF_IS_STATUS_SUCCESS(status))
		hdd_err("Invalid 11d_enable flag");
	config_vars->enable_11d_support = value;

	ucfg_mlme_get_nol_across_regdmn(hdd_ctx->psoc, &value);
	config_vars->retain_nol_across_regdmn_update = value;

	ucfg_mlme_get_scan_11d_interval(hdd_ctx->psoc, &scan_11d_interval);
	config_vars->scan_11d_interval = scan_11d_interval;

	ucfg_mlme_get_sap_country_priority(hdd_ctx->psoc,
					   &country_priority);
	config_vars->userspace_ctry_priority = country_priority;

	ucfg_scan_cfg_get_dfs_chan_scan_allowed(hdd_ctx->psoc,
						&enable_dfs_scan);

	config_vars->dfs_enabled = enable_dfs_scan;

	ucfg_mlme_get_indoor_channel_support(hdd_ctx->psoc,
					     &indoor_chan_enabled);
	config_vars->indoor_chan_enabled = indoor_chan_enabled;

	config_vars->force_ssc_disable_indoor_channel = indoor_chnl_marking;
	config_vars->band_capability = band_capability;

	ucfg_mlme_get_restart_beaconing_on_ch_avoid(hdd_ctx->psoc,
						    &restart_beaconing);
	config_vars->restart_beaconing = restart_beaconing;

	ucfg_mlme_get_etsi_srd_chan_in_master_mode(hdd_ctx->psoc,
						   &enable_srd_chan);
	config_vars->enable_srd_chan_in_master_mode = enable_srd_chan;

	ucfg_mlme_get_11d_in_world_mode(hdd_ctx->psoc,
					&config_vars->enable_11d_in_world_mode);

	ucfg_mlme_get_5dot9_ghz_chan_in_master_mode(hdd_ctx->psoc,
						    &enable_5dot9_ghz_chan);
	config_vars->enable_5dot9_ghz_chan_in_master_mode =
						enable_5dot9_ghz_chan;
	hdd_update_coex_unsafe_chan_nb_user_prefer(hdd_ctx, config_vars);
	hdd_update_coex_unsafe_chan_reg_disable(hdd_ctx, config_vars);
	config_vars->sta_sap_scc_on_indoor_channel =
		ucfg_policy_mgr_get_sta_sap_scc_on_indoor_chnl(hdd_ctx->psoc);
}

/**
 * hdd_regulatory_wiphy_init() - regulatory wiphy init
 * @hdd_ctx: hdd context
 * @reg: regulatory data
 * @wiphy: wiphy structure
 *
 * Return: void
 */

/**
 * is_wiphy_custom_regulatory() - is custom regulatory defined
 * @wiphy: wiphy
 *
 * Return: int
 */

/**
 * hdd_modify_wiphy() - modify wiphy
 * @wiphy: wiphy
 * @chan: channel structure
 *
 * Return: void
 */

/**
 * hdd_set_dfs_region() - set the dfs_region
 * @dfs_region: the dfs_region to set
 *
 * Return: void
 */

/**
 * hdd_process_regulatory_data() - process regulatory data
 * @hdd_ctx: hdd context
 * @wiphy: wiphy
 * @reset: whether to reset channel data
 *
 * Return: void
 */

/**
 * hdd_modify_indoor_channel_state_flags() - modify wiphy flags and cds state
 * @wiphy_chan: wiphy channel number
 * @cds_chan: cds channel structure
 * @disable: Disable/enable the flags
 *
 * Modify wiphy flags and cds state if channel is indoor.
 *
 * Return: void
 */
void hdd_modify_indoor_channel_state_flags(
	struct hdd_context *hdd_ctx,
	struct ieee80211_channel *wiphy_chan,
	struct regulatory_channel *cds_chan,
	enum channel_enum chan_enum, int chan_num, bool disable)
{
	bool indoor_support;

	ucfg_mlme_get_indoor_channel_support(hdd_ctx->psoc, &indoor_support);

	/* Mark indoor channel to disable in wiphy and cds */
	if (disable) {
		if (wiphy_chan->flags & IEEE80211_CHAN_INDOOR_ONLY) {
			wiphy_chan->flags |=
				IEEE80211_CHAN_DISABLED;
			hdd_info("Mark indoor channel %d as disable",
				cds_chan->center_freq);
			cds_chan->state =
				CHANNEL_STATE_DISABLE;
		}
	} else {
		if (wiphy_chan->flags & IEEE80211_CHAN_INDOOR_ONLY) {
			wiphy_chan->flags &=
					~IEEE80211_CHAN_DISABLED;
			 /*
			  * Indoor channels may be marked as dfs / enable
			  * during regulatory processing
			  */
			if ((wiphy_chan->flags &
				(IEEE80211_CHAN_RADAR |
				IEEE80211_CHAN_PASSIVE_SCAN)) ||
			     ((indoor_support == false) &&
				(wiphy_chan->flags &
				IEEE80211_CHAN_INDOOR_ONLY)))
				cds_chan->state =
					CHANNEL_STATE_DFS;
			else
				cds_chan->state =
					CHANNEL_STATE_ENABLE;
			hdd_debug("Mark indoor channel %d as cds_chan state %d",
					cds_chan->chan_num, cds_chan->state);
		}
	}

}

void hdd_update_indoor_channel(struct hdd_context *hdd_ctx,
					bool disable)
{
	int band_num;
	int chan_num;
	enum channel_enum chan_enum = CHAN_ENUM_2412;
	struct ieee80211_channel *wiphy_chan, *wiphy_chan_144 = NULL;
	struct regulatory_channel *cds_chan;
	uint8_t band_capability;
	struct wiphy *wiphy = hdd_ctx->wiphy;

	hdd_enter();
	hdd_debug("mark indoor channel disable: %d", disable);

	band_capability = hdd_ctx->curr_band;
	for (band_num = 0; band_num < HDD_NUM_NL80211_BANDS; band_num++) {

		if (!wiphy->bands[band_num])
			continue;

		for (chan_num = 0;
		     chan_num < wiphy->bands[band_num]->n_channels &&
		     chan_enum < NUM_CHANNELS;
		     chan_num++) {

			wiphy_chan =
				&(wiphy->bands[band_num]->channels[chan_num]);
			cds_chan = &(reg_channels[chan_enum]);
			if (chan_enum == CHAN_ENUM_5720)
				wiphy_chan_144 = wiphy_chan;

			chan_enum++;
			hdd_modify_indoor_channel_state_flags(hdd_ctx,
				wiphy_chan, cds_chan,
				chan_enum, chan_num, disable);
		}
	}

	/* Notify the regulatory domain to update the channel list */
	if (QDF_IS_STATUS_ERROR(ucfg_reg_notify_sap_event(hdd_ctx->pdev,
							  disable))) {
		hdd_err("Failed to notify sap event");
	}
	hdd_exit();

}

/**
 * hdd_program_country_code() - process channel information from country code
 * @hdd_ctx: hddc context
 *
 * Return: void
 */
void hdd_program_country_code(struct hdd_context *hdd_ctx)
{
}

void hdd_reg_wait_for_country_change(struct hdd_context *hdd_ctx)
{
	qdf_mutex_acquire(&hdd_ctx->regulatory_status_lock);
	if (hdd_ctx->is_regulatory_update_in_progress) {
		qdf_mutex_release(&hdd_ctx->regulatory_status_lock);
		hdd_debug("waiting for channel list to update");
		qdf_wait_for_event_completion(&hdd_ctx->regulatory_update_event,
					      CHANNEL_LIST_UPDATE_TIMEOUT);
		/* In case of set country failure in FW, response never comes
		 * so wait the full timeout, then set in_progress to false.
		 * If the response comes back, in_progress will already be set
		 * to false anyways.
		 */
		qdf_mutex_acquire(&hdd_ctx->regulatory_status_lock);
		hdd_ctx->is_regulatory_update_in_progress = false;
		qdf_mutex_release(&hdd_ctx->regulatory_status_lock);
	} else {
		qdf_mutex_release(&hdd_ctx->regulatory_status_lock);
	}
}

int hdd_reg_set_country(struct hdd_context *hdd_ctx, char *country_code)
{
	QDF_STATUS status;
	uint8_t cc[REG_ALPHA2_LEN + 1];
	uint8_t alpha2[REG_ALPHA2_LEN + 1];
	enum country_src cc_src;

	if (!country_code) {
		hdd_err("country_code is null");
		return -EINVAL;
	}

	qdf_mem_copy(cc, country_code, REG_ALPHA2_LEN);
	cc[REG_ALPHA2_LEN] = '\0';

	if (!qdf_mem_cmp(country_code, hdd_ctx->reg.alpha2, REG_ALPHA2_LEN)) {
		cc_src = ucfg_reg_get_cc_and_src(hdd_ctx->psoc, alpha2);
		if (cc_src == SOURCE_USERSPACE || cc_src == SOURCE_CORE) {
			hdd_debug("country code is the same");
			return 0;
		}
	}

	qdf_event_reset(&hdd_ctx->regulatory_update_event);
	qdf_mutex_acquire(&hdd_ctx->regulatory_status_lock);
	hdd_ctx->is_regulatory_update_in_progress = true;
	qdf_mutex_release(&hdd_ctx->regulatory_status_lock);

	status = ucfg_reg_set_country(hdd_ctx->pdev, cc);
	if (QDF_IS_STATUS_ERROR(status)) {
		hdd_err("Failed to set country");
		qdf_mutex_acquire(&hdd_ctx->regulatory_status_lock);
		hdd_ctx->is_regulatory_update_in_progress = false;
		qdf_mutex_release(&hdd_ctx->regulatory_status_lock);
	}

	return qdf_status_to_os_return(status);
}

uint32_t hdd_reg_legacy_setband_to_reg_wifi_band_bitmap(uint8_t qca_setband)
{
	uint32_t band_bitmap = 0;

	switch (qca_setband) {
	case QCA_SETBAND_AUTO:
		band_bitmap |= REG_BAND_MASK_ALL;
		break;
	case QCA_SETBAND_5G:
		band_bitmap |= BIT(REG_BAND_5G);
		break;
	case QCA_SETBAND_2G:
		band_bitmap |= BIT(REG_BAND_2G);
		break;
	default:
		hdd_err("Invalid band value %u", qca_setband);
		return 0;
	}

	return band_bitmap;
}

int hdd_reg_set_band(struct net_device *dev, uint32_t band_bitmap)
{
	struct hdd_adapter *adapter = WLAN_HDD_GET_PRIV_PTR(dev);
	struct hdd_context *hdd_ctx;
	uint32_t current_band;
	QDF_STATUS status;

	hdd_ctx = WLAN_HDD_GET_CTX(adapter);

	if (!band_bitmap) {
		hdd_err("Can't disable all bands");
		return -EINVAL;
	}

	hdd_debug("change band to %u", band_bitmap);

	if (ucfg_reg_get_band(hdd_ctx->pdev, &current_band) !=
	    QDF_STATUS_SUCCESS) {
		hdd_debug("Failed to get current band config");
		return -EIO;
	}

	if (current_band == band_bitmap) {
		hdd_debug("band is the same so not updating");
		return 0;
	}

	hdd_ctx->curr_band = wlan_reg_band_bitmap_to_band_info(band_bitmap);

	if (QDF_IS_STATUS_ERROR(ucfg_reg_set_band(hdd_ctx->pdev,
						  band_bitmap))) {
		hdd_err("Failed to set the band bitmap value to %u",
			band_bitmap);
		return -EINVAL;
	}

	ucfg_cm_set_roam_band_mask(hdd_ctx->psoc, adapter->vdev_id, band_bitmap);
	status = ucfg_cm_set_roam_band_update(hdd_ctx->psoc, adapter->vdev_id);
	if (QDF_IS_STATUS_ERROR(status))
		hdd_err("Failed to send RSO update to fw on set band");

	return 0;
}

/**
 * hdd_restore_custom_reg_settings() - restore custom reg settings
 * @wiphy: wiphy structure
 * @country_alpha2: alpha2 of the country
 * @reset: whether wiphy is reset
 *
 * Return: void
 */

/**
 * hdd_restore_reg_flags() - restore regulatory flags
 * @flags: regulatory flags
 *
 * Return: void
 */

/**
 * hdd_reg_notifier() - regulatory notifier
 * @wiphy: wiphy
 * @request: regulatory request
 *
 * Return: void
 */
void hdd_reg_notifier(struct wiphy *wiphy,
		      struct regulatory_request *request)
{
	QDF_STATUS status = QDF_STATUS_SUCCESS;
	struct hdd_context *hdd_ctx = wiphy_priv(wiphy);
	char country[REG_ALPHA2_LEN + 1] = {0};
	bool update_already_in_progress =
		hdd_ctx->is_regulatory_update_in_progress;

	if (cds_is_driver_unloading() || cds_is_driver_recovering() ||
	    cds_is_driver_in_bad_state()) {
		hdd_err("unloading or ssr in progress, ignore");
		return;
	}

	hdd_debug("country: %c%c, initiator %d, dfs_region: %d",
		  request->alpha2[0],
		  request->alpha2[1],
		  request->initiator,
		  request->dfs_region);

	switch (request->initiator) {
	case NL80211_REGDOM_SET_BY_USER:

		if (request->user_reg_hint_type !=
		    NL80211_USER_REG_HINT_CELL_BASE)
			return;

		qdf_event_reset(&hdd_ctx->regulatory_update_event);
		qdf_mutex_acquire(&hdd_ctx->regulatory_status_lock);
		hdd_ctx->is_regulatory_update_in_progress = true;
		qdf_mutex_release(&hdd_ctx->regulatory_status_lock);

		qdf_mem_copy(country, request->alpha2, QDF_MIN(
			     sizeof(request->alpha2), sizeof(country)));
		status = ucfg_reg_set_country(hdd_ctx->pdev, country);
		break;
	case NL80211_REGDOM_SET_BY_CORE:
	case NL80211_REGDOM_SET_BY_COUNTRY_IE:
	case NL80211_REGDOM_SET_BY_DRIVER:
	default:
		break;
	}

	if (QDF_IS_STATUS_ERROR(status) && !update_already_in_progress) {
		hdd_err("Failed to set country");
		qdf_mutex_acquire(&hdd_ctx->regulatory_status_lock);
		hdd_ctx->is_regulatory_update_in_progress = false;
		qdf_mutex_release(&hdd_ctx->regulatory_status_lock);
	}
}

#if defined(WLAN_FEATURE_11BE) && defined(CFG80211_11BE_BASIC)
static void fill_wiphy_channel_320mhz(struct ieee80211_channel *wiphy_chan,
				      uint16_t max_bw)
{
	if (max_bw < 320)
		wiphy_chan->flags |= IEEE80211_CHAN_NO_320MHZ;
}
#else
static inline
void fill_wiphy_channel_320mhz(struct ieee80211_channel *wiphy_chan,
			       uint16_t max_bw)
{
}
#endif

static void fill_wiphy_channel(struct ieee80211_channel *wiphy_chan,
			       struct regulatory_channel *cur_chan)
{

	wiphy_chan->flags = 0;
	wiphy_chan->max_power = cur_chan->tx_power;

	if (cur_chan->chan_flags & REGULATORY_CHAN_DISABLED)
		wiphy_chan->flags  |= IEEE80211_CHAN_DISABLED;
	if (cur_chan->chan_flags & REGULATORY_CHAN_NO_IR)
		wiphy_chan->flags  |= IEEE80211_CHAN_NO_IR;
	if (cur_chan->chan_flags & REGULATORY_CHAN_RADAR)
		wiphy_chan->flags  |= IEEE80211_CHAN_RADAR;
	if (cur_chan->chan_flags & REGULATORY_CHAN_NO_OFDM)
		wiphy_chan->flags  |= IEEE80211_CHAN_NO_OFDM;
	if (cur_chan->chan_flags & REGULATORY_CHAN_INDOOR_ONLY)
		wiphy_chan->flags  |= IEEE80211_CHAN_INDOOR_ONLY;

	if (cur_chan->max_bw < 10)
		wiphy_chan->flags |= IEEE80211_CHAN_NO_10MHZ;
	if (cur_chan->max_bw < 20)
		wiphy_chan->flags |= IEEE80211_CHAN_NO_20MHZ;
	if (cur_chan->max_bw < 40)
		wiphy_chan->flags |= IEEE80211_CHAN_NO_HT40;
	if (cur_chan->max_bw < 80)
		wiphy_chan->flags |= IEEE80211_CHAN_NO_80MHZ;
	if (cur_chan->max_bw < 160)
		wiphy_chan->flags |= IEEE80211_CHAN_NO_160MHZ;

	fill_wiphy_channel_320mhz(wiphy_chan, cur_chan->max_bw);

	wiphy_chan->orig_flags = wiphy_chan->flags;
}

static void fill_wiphy_band_channels(struct wiphy *wiphy,
				     struct regulatory_channel *cur_chan_list,
				     uint8_t band_id)
{
	uint32_t wiphy_num_chan, wiphy_index;
	uint32_t chan_cnt;
	struct ieee80211_channel *wiphy_chan;

	if (!wiphy->bands[band_id])
		return;

	wiphy_num_chan = wiphy->bands[band_id]->n_channels;
	wiphy_chan = wiphy->bands[band_id]->channels;

	for (wiphy_index = 0; wiphy_index < wiphy_num_chan; wiphy_index++) {
		for (chan_cnt = 0; chan_cnt < NUM_CHANNELS; chan_cnt++) {
			if (wiphy_chan[wiphy_index].center_freq ==
			    cur_chan_list[chan_cnt].center_freq) {
				fill_wiphy_channel(&(wiphy_chan[wiphy_index]),
						   &(cur_chan_list[chan_cnt]));
				break;
			}
		}
	}
}

#ifdef FEATURE_WLAN_CH_AVOID
/**
 * hdd_ch_avoid_ind() - Avoid notified channels from FW handler
 * @adapter:	HDD adapter pointer
 * @indParam:	Channel avoid notification parameter
 *
 * Avoid channel notification from FW handler.
 * FW will send un-safe channel list to avoid over wrapping.
 * hostapd should not use notified channel
 *
 * Return: None
 */
void hdd_ch_avoid_ind(struct hdd_context *hdd_ctxt,
		struct unsafe_ch_list *unsafe_chan_list,
		struct ch_avoid_ind_type *avoid_freq_list)
{
	uint16_t *local_unsafe_list;
	uint16_t local_unsafe_list_count;
	uint32_t restriction_mask;
	uint8_t i;

	/* Basic sanity */
	if (!hdd_ctxt) {
		hdd_err("Invalid arguments");
		return;
	}

	mutex_lock(&hdd_ctxt->avoid_freq_lock);
	qdf_mem_copy(&hdd_ctxt->coex_avoid_freq_list, avoid_freq_list,
			sizeof(struct ch_avoid_ind_type));
	mutex_unlock(&hdd_ctxt->avoid_freq_lock);

	restriction_mask = wlan_hdd_get_restriction_mask(hdd_ctxt);
	if (hdd_clone_local_unsafe_chan(hdd_ctxt,
					&local_unsafe_list,
					&local_unsafe_list_count) != 0) {
		hdd_err("failed to clone cur unsafe chan list");
		return;
	}

	/* clear existing unsafe channel cache */
	hdd_ctxt->unsafe_channel_count = 0;
	qdf_mem_zero(hdd_ctxt->unsafe_channel_list,
					sizeof(hdd_ctxt->unsafe_channel_list));

	hdd_ctxt->unsafe_channel_count = unsafe_chan_list->chan_cnt;

	wlan_hdd_set_restriction_mask(hdd_ctxt);

	for (i = 0; i < unsafe_chan_list->chan_cnt; i++) {
		hdd_ctxt->unsafe_channel_list[i] =
				unsafe_chan_list->chan_freq_list[i];
	}
	hdd_debug("number of unsafe channels is %d ",
	       hdd_ctxt->unsafe_channel_count);

	if (pld_set_wlan_unsafe_channel(hdd_ctxt->parent_dev,
					hdd_ctxt->unsafe_channel_list,
				hdd_ctxt->unsafe_channel_count)) {
		hdd_err("Failed to set unsafe channel");

		/* clear existing unsafe channel cache */
		hdd_ctxt->unsafe_channel_count = 0;
		qdf_mem_zero(hdd_ctxt->unsafe_channel_list,
			sizeof(hdd_ctxt->unsafe_channel_list));
		qdf_mem_free(local_unsafe_list);
		return;
	}

	mutex_lock(&hdd_ctxt->avoid_freq_lock);
	if (hdd_ctxt->dnbs_avoid_freq_list.ch_avoid_range_cnt)
		if (wlan_hdd_merge_avoid_freqs(avoid_freq_list,
					&hdd_ctxt->dnbs_avoid_freq_list)) {
			mutex_unlock(&hdd_ctxt->avoid_freq_lock);
			hdd_debug("unable to merge avoid freqs");
			qdf_mem_free(local_unsafe_list);
			return;
	}
	mutex_unlock(&hdd_ctxt->avoid_freq_lock);
	/*
	 * first update the unsafe channel list to the platform driver and
	 * send the avoid freq event to the application
	 */
	wlan_hdd_send_avoid_freq_event(hdd_ctxt, avoid_freq_list);

	if (!hdd_ctxt->unsafe_channel_count) {
		hdd_debug("no unsafe channels - not restarting SAP");
		qdf_mem_free(local_unsafe_list);
		return;
	}
	if (hdd_local_unsafe_channel_updated(hdd_ctxt,
					    local_unsafe_list,
					    local_unsafe_list_count,
					    restriction_mask))
		hdd_unsafe_channel_restart_sap(hdd_ctxt);
	qdf_mem_free(local_unsafe_list);

}
#endif

static void map_nl_reg_rule_flags(uint16_t drv_reg_rule_flag,
				  uint32_t *regd_rule_flag)
{
	if (drv_reg_rule_flag & REGULATORY_CHAN_NO_IR)
		*regd_rule_flag |= NL80211_RRF_NO_IR;
	if (drv_reg_rule_flag & REGULATORY_CHAN_RADAR)
		*regd_rule_flag |= NL80211_RRF_DFS;
	if (drv_reg_rule_flag & REGULATORY_CHAN_INDOOR_ONLY)
		*regd_rule_flag |= NL80211_RRF_NO_OUTDOOR;
	if (drv_reg_rule_flag & REGULATORY_CHAN_NO_OFDM)
		*regd_rule_flag |= NL80211_RRF_NO_OFDM;
	*regd_rule_flag |= NL80211_RRF_AUTO_BW;
}

/**
 * dfs_reg_to_nl80211_dfs_regions() - convert dfs_reg to nl80211_dfs_regions
 * @dfs_region: DFS region
 *
 * Return: nl80211_dfs_regions
 */
static enum nl80211_dfs_regions dfs_reg_to_nl80211_dfs_regions(
					enum dfs_reg dfs_region)
{
	switch (dfs_region) {
	case DFS_UNINIT_REGION:
		return NL80211_DFS_UNSET;
	case DFS_FCC_REGION:
		return NL80211_DFS_FCC;
	case DFS_ETSI_REGION:
		return NL80211_DFS_ETSI;
	case DFS_MKK_REGION:
		return NL80211_DFS_JP;
	default:
		return NL80211_DFS_UNSET;
	}
}

/**
 * hdd_set_dfs_pri_multiplier() - Set dfs_pri_multiplier for ETSI region
 * @dfs_region: DFS region
 *
 * Return: none
 */
#ifdef DFS_PRI_MULTIPLIER
static void hdd_set_dfs_pri_multiplier(struct hdd_context *hdd_ctx,
				       enum dfs_reg dfs_region)
{
	if (dfs_region == DFS_ETSI_REGION)
		wlan_sap_set_dfs_pri_multiplier(hdd_ctx->mac_handle);
}
#else
static inline void hdd_set_dfs_pri_multiplier(struct hdd_context *hdd_ctx,
					      enum dfs_reg dfs_region)
{
}
#endif

void hdd_send_wiphy_regd_sync_event(struct hdd_context *hdd_ctx)
{
	struct ieee80211_regdomain *regd;
	struct ieee80211_reg_rule *regd_rules;
	struct reg_rule_info reg_rules_struct;
	struct reg_rule_info *reg_rules;
	QDF_STATUS  status;
	uint8_t i;

	if (!hdd_ctx) {
		hdd_err("hdd_ctx is NULL");
		return;
	}

	status = ucfg_reg_get_regd_rules(hdd_ctx->pdev, &reg_rules_struct);
	if (QDF_IS_STATUS_ERROR(status)) {
		hdd_err("could not get reg rules");
		return;
	}

	reg_rules = &reg_rules_struct;
	if (!reg_rules->num_of_reg_rules) {
		hdd_err("no reg rules %d", reg_rules->num_of_reg_rules);
		return;
	}

	regd = qdf_mem_malloc((reg_rules->num_of_reg_rules *
				sizeof(*regd_rules) + sizeof(*regd)));
	if (!regd)
		return;

	regd->n_reg_rules = reg_rules->num_of_reg_rules;
	qdf_mem_copy(regd->alpha2, reg_rules->alpha2, REG_ALPHA2_LEN + 1);
	regd->dfs_region =
		dfs_reg_to_nl80211_dfs_regions(reg_rules->dfs_region);

	hdd_set_dfs_pri_multiplier(hdd_ctx, reg_rules->dfs_region);

	regd_rules = regd->reg_rules;
	hdd_debug("Regulatory Domain %s", regd->alpha2);
	hdd_debug("start freq\tend freq\t@ max_bw\tant_gain\tpwr\tflags");
	for (i = 0; i < reg_rules->num_of_reg_rules; i++) {
		regd_rules[i].freq_range.start_freq_khz =
			reg_rules->reg_rules[i].start_freq * 1000;
		regd_rules[i].freq_range.end_freq_khz =
			reg_rules->reg_rules[i].end_freq * 1000;
		regd_rules[i].freq_range.max_bandwidth_khz =
			reg_rules->reg_rules[i].max_bw * 1000;
		regd_rules[i].power_rule.max_antenna_gain =
			reg_rules->reg_rules[i].ant_gain * 100;
		regd_rules[i].power_rule.max_eirp =
			reg_rules->reg_rules[i].reg_power * 100;
		map_nl_reg_rule_flags(reg_rules->reg_rules[i].flags,
				      &regd_rules[i].flags);
		hdd_debug("%d KHz\t%d KHz\t@ %d KHz\t%d\t\t%d\t%d",
			  regd_rules[i].freq_range.start_freq_khz,
			  regd_rules[i].freq_range.end_freq_khz,
			  regd_rules[i].freq_range.max_bandwidth_khz,
			  regd_rules[i].power_rule.max_antenna_gain,
			  regd_rules[i].power_rule.max_eirp,
			  regd_rules[i].flags);
	}

	regulatory_set_wiphy_regd(hdd_ctx->wiphy, regd);

	hdd_debug("regd sync event sent with reg rules info");
	qdf_mem_free(regd);
}

#if defined(CONFIG_BAND_6GHZ)
static void
fill_wiphy_6ghz_band_channels(struct wiphy *wiphy,
			      struct regulatory_channel *chan_list)
{
	fill_wiphy_band_channels(wiphy, chan_list, NL80211_BAND_6GHZ);
}
#else
static void
fill_wiphy_6ghz_band_channels(struct wiphy *wiphy,
			      struct regulatory_channel *chan_list)
{
}
#endif

#define HDD_MAX_CHAN_INFO_LOG 192

/**
 * hdd_regulatory_chanlist_dump() - Dump regulatory channel list info
 * @chan_list: regulatory channel list
 *
 * Return: void
 */
static void hdd_regulatory_chanlist_dump(struct regulatory_channel *chan_list)
{
	uint32_t i;
	uint8_t info[HDD_MAX_CHAN_INFO_LOG];
	int len = 0;
	struct regulatory_channel *chan;
	uint32_t count = 0;
	int ret;

	hdd_debug("start (freq MHz, tx power dBm):");
	for (i = 0; i < NUM_CHANNELS; i++) {
		chan = &chan_list[i];
		if ((chan->chan_flags & REGULATORY_CHAN_DISABLED))
			continue;
		count++;
		ret = scnprintf(info + len, sizeof(info) - len, "%d %d ",
				chan->center_freq, chan->tx_power);
		if (ret <= 0)
			break;
		len += ret;
		if (len >= (sizeof(info) - 20)) {
			hdd_debug("%s", info);
			len = 0;
		}
	}
	if (len > 0)
		hdd_debug("%s", info);
	hdd_debug("end total_count %d", count);
}

#ifdef FEATURE_WLAN_CH_AVOID_EXT
/**
 * hdd_country_change_bw_check() - Check if bandwidth changed
 * @hdd_ctx: Global HDD context
 * @adapter: HDD vdev context
 * @oper_freq: current frequency of adapter
 *
 * Return: true if bandwidth changed otherwise false.
 */
static bool
hdd_country_change_bw_check(struct hdd_context *hdd_ctx,
			    struct hdd_adapter *adapter,
			    qdf_freq_t oper_freq)
{
	bool width_changed = false;
	enum phy_ch_width width;
	uint16_t org_bw = 0;
	struct regulatory_channel *cur_chan_list = NULL;
	int i;

	cur_chan_list = qdf_mem_malloc(sizeof(*cur_chan_list) * NUM_CHANNELS);
	if (!cur_chan_list)
		return false;

	ucfg_reg_get_current_chan_list(hdd_ctx->pdev,
				       cur_chan_list);

	width = hdd_get_adapter_width(adapter);
	org_bw = wlan_reg_get_bw_value(width);

	for (i = 0; i < NUM_CHANNELS; i++) {
		if (cur_chan_list[i].state ==
			CHANNEL_STATE_DISABLE)
			continue;

		if (cur_chan_list[i].center_freq == oper_freq &&
		    org_bw > cur_chan_list[i].max_bw) {
			width_changed = true;
			break;
		}
	}
	qdf_mem_free(cur_chan_list);
	return width_changed;
}
#else
static inline bool
hdd_country_change_bw_check(struct hdd_context *hdd_ctx,
			    struct hdd_adapter *adapter,
			    qdf_freq_t oper_freq)
{
	return false;
}
#endif

/**
 * hdd_country_change_update_sta() - handle country code change for STA
 * @hdd_ctx: Global HDD context
 *
 * This function handles the stop/start/restart of STA/P2P_CLI adapters when
 * the country code changes
 *
 * Return: none
 */
static void hdd_country_change_update_sta(struct hdd_context *hdd_ctx)
{
	struct hdd_adapter *adapter = NULL, *next_adapter = NULL;
	struct hdd_station_ctx *sta_ctx = NULL;
	struct wlan_objmgr_pdev *pdev = NULL;
	uint32_t new_phy_mode;
	bool freq_changed, phy_changed, width_changed;
	qdf_freq_t oper_freq;
	eCsrPhyMode csr_phy_mode;
	wlan_net_dev_ref_dbgid dbgid = NET_DEV_HOLD_COUNTRY_CHANGE_UPDATE_STA;

	pdev = hdd_ctx->pdev;

	hdd_for_each_adapter_dev_held_safe(hdd_ctx, adapter, next_adapter,
					   dbgid) {
		width_changed = false;
		oper_freq = hdd_get_adapter_home_channel(adapter);
		if (oper_freq)
			freq_changed = wlan_reg_is_disable_for_freq(pdev,
								    oper_freq);
		else
			freq_changed = false;

		switch (adapter->device_mode) {
		case QDF_P2P_CLIENT_MODE:
			/*
			 * P2P client is the same as STA
			 * continue to next statement
			 */
		case QDF_STA_MODE:
			sta_ctx = WLAN_HDD_GET_STATION_CTX_PTR(adapter);
			new_phy_mode = wlan_reg_get_max_phymode(pdev,
								REG_PHYMODE_MAX,
								oper_freq);
			csr_phy_mode =
				csr_convert_from_reg_phy_mode(new_phy_mode);
			phy_changed = (sta_ctx->reg_phymode != csr_phy_mode);

			width_changed = hdd_country_change_bw_check(hdd_ctx,
								    adapter,
								    oper_freq);

			if (hdd_is_vdev_in_conn_state(adapter) &&
			    (phy_changed || freq_changed || width_changed)) {
				hdd_debug("changed: phy %d, freq %d, width %d",
					  phy_changed, freq_changed,
					  width_changed);
				wlan_hdd_cm_issue_disconnect(adapter,
							REASON_UNSPEC_FAILURE,
							false);
				sta_ctx->reg_phymode = csr_phy_mode;
			}
			break;
		default:
			break;
		}
		/* dev_put has to be done here */
		hdd_adapter_dev_put_debug(adapter, dbgid);
	}
}

/**
 * hdd_restart_sap_with_new_phymode() - restart the SAP with the new phymode
 * @hdd_ctx: Global HDD context
 * @adapter: HDD vdev context
 * @sap_config: sap configuration pointer
 * @csr_phy_mode: phymode to restart SAP with
 *
 * This function handles the stop/start/restart of SAP/P2P_GO adapters when the
 * country code changes
 *
 * Return: none
 */
static void hdd_restart_sap_with_new_phymode(struct hdd_context *hdd_ctx,
					     struct hdd_adapter *adapter,
					     struct sap_config *sap_config,
					     eCsrPhyMode csr_phy_mode)
{
	struct hdd_hostapd_state *hostapd_state = NULL;
	struct sap_context *sap_ctx = NULL;
	QDF_STATUS status;

	hostapd_state = WLAN_HDD_GET_HOSTAP_STATE_PTR(adapter);
	sap_ctx = WLAN_HDD_GET_SAP_CTX_PTR(adapter);

	if (!test_bit(SOFTAP_BSS_STARTED, &adapter->event_flags)) {
		sap_config->sap_orig_hw_mode = sap_config->SapHw_mode;
		sap_config->SapHw_mode = csr_phy_mode;
		hdd_err("Can't restart AP because it is not started");
		return;
	}

	qdf_event_reset(&hostapd_state->qdf_stop_bss_event);
	status = wlansap_stop_bss(sap_ctx);
	if (!QDF_IS_STATUS_SUCCESS(status)) {
		hdd_err("SAP Stop Bss fail");
		return;
	}
	status = qdf_wait_single_event(&hostapd_state->qdf_stop_bss_event,
				       SME_CMD_STOP_BSS_TIMEOUT);
	if (!QDF_IS_STATUS_SUCCESS(status)) {
		hdd_err("SAP Stop timeout");
		return;
	}

	sap_config->chan_freq =
		wlansap_get_safe_channel_from_pcl_and_acs_range(sap_ctx);

	sap_config->sap_orig_hw_mode = sap_config->SapHw_mode;
	sap_config->SapHw_mode = csr_phy_mode;

	mutex_lock(&hdd_ctx->sap_lock);
	qdf_event_reset(&hostapd_state->qdf_event);
	status = wlansap_start_bss(sap_ctx, hdd_hostapd_sap_event_cb,
				   sap_config, adapter->dev);
	if (!QDF_IS_STATUS_SUCCESS(status)) {
		mutex_unlock(&hdd_ctx->sap_lock);
		hdd_err("SAP Start Bss fail");
		return;
	}
	status = qdf_wait_single_event(&hostapd_state->qdf_event,
				       SME_CMD_START_BSS_TIMEOUT);
	if (!QDF_IS_STATUS_SUCCESS(status)) {
		mutex_unlock(&hdd_ctx->sap_lock);
		hdd_err("SAP Start timeout");
		return;
	}
	mutex_unlock(&hdd_ctx->sap_lock);
}

static bool
hdd_is_sap_with_new_chan_width_needed(struct wlan_objmgr_psoc *psoc,
				      struct wlan_objmgr_pdev *pdev,
				      struct sap_config *sap_config,
				      qdf_freq_t oper_freq,
				      struct hdd_adapter *adapter)
{
	enum phy_ch_width new_ch_width;

	new_ch_width = sap_config->ch_params.ch_width;

	/* Force SAP to 20MHz if INI is enabled, country is Indonesia
	 * and device mode is SAP
	 */
	if (sap_config->ch_params.ch_width != CH_WIDTH_20MHZ &&
	    adapter->vdev &&
	    policy_mgr_get_sap_force_20mhz_for_country_id(
			psoc, adapter->vdev, oper_freq)) {
		hdd_debug("Force SAP to 20MHz due to INI and country code ID");
		new_ch_width = CH_WIDTH_20MHZ;
	}

	return (new_ch_width != sap_config->ch_params.ch_width);
}

/**
 * hdd_country_change_update_sap() - handle country code change for SAP
 * @hdd_ctx: Global HDD context
 *
 * This function handles the stop/start/restart of SAP/P2P_GO adapters when the
 * country code changes
 *
 * Return: none
 */
static void hdd_country_change_update_sap(struct hdd_context *hdd_ctx)
{
	struct hdd_adapter *adapter = NULL, *next_adapter = NULL;
	struct sap_config *sap_config = NULL;
	struct wlan_objmgr_pdev *pdev = NULL;
	uint32_t reg_phy_mode, new_phy_mode;
	bool phy_changed;
	bool chan_width_changed;
	qdf_freq_t oper_freq;
	eCsrPhyMode csr_phy_mode;
	wlan_net_dev_ref_dbgid dbgid = NET_DEV_HOLD_COUNTRY_CHANGE_UPDATE_SAP;

	pdev = hdd_ctx->pdev;

	hdd_for_each_adapter_dev_held_safe(hdd_ctx, adapter, next_adapter,
					   dbgid) {
		oper_freq = hdd_get_adapter_home_channel(adapter);

		switch (adapter->device_mode) {
		case QDF_P2P_GO_MODE:
			policy_mgr_check_sap_restart(hdd_ctx->psoc,
						     adapter->vdev_id);
			break;
		case QDF_SAP_MODE:
			if (!test_bit(SOFTAP_INIT_DONE,
				      &adapter->event_flags)) {
				hdd_info("AP is not started yet");
				break;
			}
			sap_config = &adapter->session.ap.sap_config;
			reg_phy_mode = csr_convert_to_reg_phy_mode(
						sap_config->sap_orig_hw_mode,
						oper_freq);
			new_phy_mode = wlan_reg_get_max_phymode(pdev,
								reg_phy_mode,
								oper_freq);
			csr_phy_mode =
				csr_convert_from_reg_phy_mode(new_phy_mode);
			phy_changed = (csr_phy_mode != sap_config->SapHw_mode);

			chan_width_changed =
				hdd_is_sap_with_new_chan_width_needed(
							hdd_ctx->psoc,
							pdev,
							sap_config,
							oper_freq,
							adapter);
			hdd_debug("phy_changes: %d, chan_width_changed: %d",
				  phy_changed, chan_width_changed);

			if (phy_changed) {
				hdd_restart_sap_with_new_phymode(hdd_ctx,
								 adapter,
								 sap_config,
								 csr_phy_mode);
			} else if (chan_width_changed &&
				   QDF_IS_STATUS_SUCCESS(
				policy_mgr_change_sap_channel_with_csa(
							hdd_ctx->psoc,
							adapter->vdev_id,
							oper_freq,
							CH_WIDTH_20MHZ,
							true))) {
				hdd_debug("SAP CSA due to chan width changed BW 20 MHz");
			} else {
				policy_mgr_check_sap_restart(hdd_ctx->psoc,
							     adapter->vdev_id);
			}
			break;
		default:
			break;
		}
		/* dev_put has to be done here */
		hdd_adapter_dev_put_debug(adapter, dbgid);
	}
}

static void __hdd_country_change_work_handle(struct hdd_context *hdd_ctx)
{
	/*
	 * Loop over STAs first since it may lead to different channel
	 * selection for SAPs
	 */
	hdd_country_change_update_sta(hdd_ctx);
	sme_generic_change_country_code(hdd_ctx->mac_handle,
					hdd_ctx->reg.alpha2);

	qdf_event_set(&hdd_ctx->regulatory_update_event);
	qdf_mutex_acquire(&hdd_ctx->regulatory_status_lock);
	hdd_ctx->is_regulatory_update_in_progress = false;
	qdf_mutex_release(&hdd_ctx->regulatory_status_lock);

	hdd_country_change_update_sap(hdd_ctx);
}

/**
 * hdd_country_change_work_handle() - handle country code change
 * @arg: Global HDD context
 *
 * This function handles the stop/start/restart of all adapters when the
 * country code changes
 *
 * Return: none
 */
static void hdd_country_change_work_handle(void *arg)
{
	struct hdd_context *hdd_ctx = (struct hdd_context *)arg;
	struct osif_psoc_sync *psoc_sync;
	int errno;

	errno = wlan_hdd_validate_context(hdd_ctx);
	if (errno)
		return;

	errno = osif_psoc_sync_op_start(wiphy_dev(hdd_ctx->wiphy), &psoc_sync);

	if (errno == -EAGAIN) {
		qdf_sleep(COUNTRY_CHANGE_WORK_RESCHED_WAIT_TIME);
		hdd_debug("rescheduling country change work");
		qdf_sched_work(0, &hdd_ctx->country_change_work);
		return;
	} else if (errno) {
		hdd_err("can not handle country change %d", errno);
		return;
	}

	__hdd_country_change_work_handle(hdd_ctx);

	osif_psoc_sync_op_stop(psoc_sync);
}

static void hdd_regulatory_dyn_cbk(struct wlan_objmgr_psoc *psoc,
				   struct wlan_objmgr_pdev *pdev,
				   struct regulatory_channel *chan_list,
				   struct avoid_freq_ind_data *avoid_freq_ind,
				   void *arg)
{
	struct wiphy *wiphy;
	struct pdev_osif_priv *pdev_priv;
	struct hdd_context *hdd_ctx;
	enum country_src cc_src;
	uint8_t alpha2[REG_ALPHA2_LEN + 1];

	pdev_priv = wlan_pdev_get_ospriv(pdev);
	wiphy = pdev_priv->wiphy;
	hdd_ctx = wiphy_priv(wiphy);

	if (avoid_freq_ind) {
		hdd_ch_avoid_ind(hdd_ctx, &avoid_freq_ind->chan_list,
				 &avoid_freq_ind->freq_list);
		return;
	}

	hdd_debug("process channel list update from regulatory");
	hdd_regulatory_chanlist_dump(chan_list);

	fill_wiphy_band_channels(wiphy, chan_list, NL80211_BAND_2GHZ);
	fill_wiphy_band_channels(wiphy, chan_list, NL80211_BAND_5GHZ);
	fill_wiphy_6ghz_band_channels(wiphy, chan_list);
	cc_src = ucfg_reg_get_cc_and_src(hdd_ctx->psoc, alpha2);
	qdf_mem_copy(hdd_ctx->reg.alpha2, alpha2, REG_ALPHA2_LEN + 1);

	/* Check the kernel version for upstream commit aced43ce780dc5 that
	 * has support for processing user cell_base hints when wiphy is
	 * self managed or check the backport flag for the same.
	 */
	if (wiphy->registered)
		hdd_send_wiphy_regd_sync_event(hdd_ctx);

	hdd_config_tdls_with_band_switch(hdd_ctx);
	qdf_sched_work(0, &hdd_ctx->country_change_work);
}

int hdd_update_regulatory_config(struct hdd_context *hdd_ctx)
{
	struct reg_config_vars config_vars;

	reg_program_config_vars(hdd_ctx, &config_vars);
	ucfg_reg_set_config_vars(hdd_ctx->psoc, config_vars);
	return 0;
}

int hdd_init_regulatory_update_event(struct hdd_context *hdd_ctx)
{
	QDF_STATUS status;

	status = qdf_event_create(&hdd_ctx->regulatory_update_event);
	if (QDF_IS_STATUS_ERROR(status)) {
		hdd_err("Failed to create regulatory update event");
		goto failure;
	}
	status = qdf_mutex_create(&hdd_ctx->regulatory_status_lock);
	if (QDF_IS_STATUS_ERROR(status)) {
		hdd_err("Failed to create regulatory status mutex");
		goto failure;
	}
	hdd_ctx->is_regulatory_update_in_progress = false;

failure:
	return qdf_status_to_os_return(status);
}

int hdd_regulatory_init(struct hdd_context *hdd_ctx, struct wiphy *wiphy)
{
	bool offload_enabled;
	struct regulatory_channel *cur_chan_list;
	enum country_src cc_src;
	uint8_t alpha2[REG_ALPHA2_LEN + 1];

	cur_chan_list = qdf_mem_malloc(sizeof(*cur_chan_list) * NUM_CHANNELS);
	if (!cur_chan_list) {
		return -ENOMEM;
	}

	qdf_create_work(0, &hdd_ctx->country_change_work,
			hdd_country_change_work_handle, hdd_ctx);
	ucfg_reg_register_chan_change_callback(hdd_ctx->psoc,
					       hdd_regulatory_dyn_cbk,
					       NULL);

	wiphy->regulatory_flags |= REGULATORY_WIPHY_SELF_MANAGED;
	/* Check the kernel version for upstream commit aced43ce780dc5 that
	 * has support for processing user cell_base hints when wiphy is
	 * self managed or check the backport flag for the same.
	 */
	wiphy->features |= NL80211_FEATURE_CELL_BASE_REG_HINTS;
	wiphy->reg_notifier = hdd_reg_notifier;
	offload_enabled = ucfg_reg_is_regdb_offloaded(hdd_ctx->psoc);
	hdd_debug("regulatory offload_enabled %d", offload_enabled);
	if (offload_enabled) {
		hdd_ctx->reg_offload = true;
		ucfg_reg_get_current_chan_list(hdd_ctx->pdev,
					       cur_chan_list);
		hdd_regulatory_chanlist_dump(cur_chan_list);
		fill_wiphy_band_channels(wiphy, cur_chan_list,
					 NL80211_BAND_2GHZ);
		fill_wiphy_band_channels(wiphy, cur_chan_list,
					 NL80211_BAND_5GHZ);
		fill_wiphy_6ghz_band_channels(wiphy, cur_chan_list);
		cc_src = ucfg_reg_get_cc_and_src(hdd_ctx->psoc, alpha2);
		qdf_mem_copy(hdd_ctx->reg.alpha2, alpha2, REG_ALPHA2_LEN + 1);
	} else {
		hdd_ctx->reg_offload = false;
	}

	qdf_mem_free(cur_chan_list);
	return 0;
}


void hdd_deinit_regulatory_update_event(struct hdd_context *hdd_ctx)
{
	QDF_STATUS status;

	status = qdf_event_destroy(&hdd_ctx->regulatory_update_event);
	if (QDF_IS_STATUS_ERROR(status))
		hdd_err("Failed to destroy regulatory update event");
	status = qdf_mutex_destroy(&hdd_ctx->regulatory_status_lock);
	if (QDF_IS_STATUS_ERROR(status))
		hdd_err("Failed to destroy regulatory status mutex");
}

void hdd_regulatory_deinit(struct hdd_context *hdd_ctx)
{
	qdf_flush_work(&hdd_ctx->country_change_work);
	qdf_destroy_work(0, &hdd_ctx->country_change_work);
}

void hdd_update_regdb_offload_config(struct hdd_context *hdd_ctx)
{
	bool ignore_fw_reg_offload_ind = false;

	ucfg_mlme_get_ignore_fw_reg_offload_ind(hdd_ctx->psoc,
						&ignore_fw_reg_offload_ind);
	if (!ignore_fw_reg_offload_ind) {
		hdd_debug("regdb offload is based on firmware capability");
		return;
	}

	hdd_debug("Ignore regdb offload Indication from FW");
	ucfg_set_ignore_fw_reg_offload_ind(hdd_ctx->psoc);
}
