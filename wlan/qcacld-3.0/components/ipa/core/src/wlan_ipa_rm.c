/*
 * Copyright (c) 2013-2021 The Linux Foundation. All rights reserved.
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

/* Include Files */
#include "qdf_delayed_work.h"
#include "wlan_ipa_core.h"
#include "wlan_ipa_main.h"
#include "cdp_txrx_ipa.h"
#include "host_diag_core_event.h"

QDF_STATUS wlan_ipa_set_perf_level(struct wlan_ipa_priv *ipa_ctx,
				    uint64_t tx_packets,
				    uint64_t rx_packets)
{
	int ret;
	uint32_t next_bw;
	uint64_t total_packets = tx_packets + rx_packets;

	if ((!wlan_ipa_is_enabled(ipa_ctx->config)) ||
		(!wlan_ipa_is_clk_scaling_enabled(ipa_ctx->config)))
		return 0;

	if (total_packets > (ipa_ctx->config->bus_bw_high / 2))
		next_bw = ipa_ctx->config->ipa_bw_high;
	else if (total_packets > (ipa_ctx->config->bus_bw_medium / 2))
		next_bw = ipa_ctx->config->ipa_bw_medium;
	else
		next_bw = ipa_ctx->config->ipa_bw_low;

	if (ipa_ctx->curr_cons_bw != next_bw) {
		ipa_debug("Requesting IPA perf curr: %d, next: %d",
			  ipa_ctx->curr_cons_bw, next_bw);
		ret = cdp_ipa_set_perf_level(ipa_ctx->dp_soc,
					     QDF_IPA_CLIENT_WLAN1_CONS,
					     next_bw);
		if (ret) {
			ipa_err("RM CONS set perf profile failed: %d", ret);

			return QDF_STATUS_E_FAILURE;
		}
		ret = cdp_ipa_set_perf_level(ipa_ctx->dp_soc,
					     QDF_IPA_CLIENT_WLAN1_PROD,
					     next_bw);
		if (ret) {
			ipa_err("RM PROD set perf profile failed: %d", ret);
			return QDF_STATUS_E_FAILURE;
		}
		ipa_ctx->curr_cons_bw = next_bw;
		ipa_ctx->stats.num_cons_perf_req++;
	}

	return QDF_STATUS_SUCCESS;
}

QDF_STATUS wlan_ipa_init_perf_level(struct wlan_ipa_priv *ipa_ctx)
{
	int ret;

	/* Set lowest bandwidth to start with */
	if (wlan_ipa_is_clk_scaling_enabled(ipa_ctx->config))
		return wlan_ipa_set_perf_level(ipa_ctx, 0, 0);

	ipa_debug("IPA clk scaling disabled. Set perf level to maximum %d",
		  WLAN_IPA_MAX_BANDWIDTH);

	ret = cdp_ipa_set_perf_level(ipa_ctx->dp_soc,
				     QDF_IPA_CLIENT_WLAN1_CONS,
				     WLAN_IPA_MAX_BANDWIDTH);
	if (ret) {
		ipa_err("CONS set perf profile failed: %d", ret);
		return QDF_STATUS_E_FAILURE;
	}

	ret = cdp_ipa_set_perf_level(ipa_ctx->dp_soc,
				     QDF_IPA_CLIENT_WLAN1_PROD,
				     WLAN_IPA_MAX_BANDWIDTH);
	if (ret) {
		ipa_err("PROD set perf profile failed: %d", ret);
		return QDF_STATUS_E_FAILURE;
	}

	return QDF_STATUS_SUCCESS;
}

#ifdef FEATURE_METERING
void wlan_ipa_init_metering(struct wlan_ipa_priv *ipa_ctx)
{
	qdf_event_create(&ipa_ctx->ipa_uc_sharing_stats_comp);
	qdf_event_create(&ipa_ctx->ipa_uc_set_quota_comp);
}
#endif
