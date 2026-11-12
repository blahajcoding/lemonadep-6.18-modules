/*
 * Copyright (c) 2017-2021, The Linux Foundation. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef _QDF_IPA_H
#define _QDF_IPA_H

#ifdef IPA_OFFLOAD

#include <i_qdf_ipa.h>

/**
 * enum qdf_ipa_wlan_event - QDF IPA events
 * @QDF_IPA_CLIENT_CONNECT: Client Connects
 * @QDF_IPA_CLIENT_DISCONNECT: Client Disconnects
 * @QDF_IPA_AP_CONNECT: SoftAP is started
 * @QDF_IPA_AP_DISCONNECT: SoftAP is stopped
 * @QDF_IPA_STA_CONNECT: STA associates to AP
 * @QDF_IPA_STA_DISCONNECT: STA dissociates from AP
 * @QDF_IPA_CLIENT_CONNECT_EX: Peer associates/re-associates to softap
 * @QDF_SWITCH_TO_SCC: WLAN interfaces in scc mode
 * @QDF_SWITCH_TO_MCC: WLAN interfaces in mcc mode
 * @QDF_WDI_ENABLE: WDI enable complete
 * @QDF_WDI_DISABLE: WDI teardown
 * @QDF_FWR_SSR_BEFORE_SHUTDOWN: WLAN FW recovery
 * @QDF_IPA_WLAN_EVENT_MAX: Max value for the enum
 */
typedef enum {
	QDF_IPA_CLIENT_CONNECT,
	QDF_IPA_CLIENT_DISCONNECT,
	QDF_IPA_AP_CONNECT,
	QDF_IPA_AP_DISCONNECT,
	QDF_IPA_STA_CONNECT,
	QDF_IPA_STA_DISCONNECT,
	QDF_IPA_CLIENT_CONNECT_EX,
	QDF_SWITCH_TO_SCC,
	QDF_SWITCH_TO_MCC,
	QDF_WDI_ENABLE,
	QDF_WDI_DISABLE,
	QDF_FWR_SSR_BEFORE_SHUTDOWN,
	QDF_IPA_WLAN_EVENT_MAX
} qdf_ipa_wlan_event;

/**
 * qdf_ipa_wdi_meter_evt_type_t - type of event client callback is
 * for AP+STA mode metering
 * @IPA_GET_WDI_SAP_STATS: get IPA_stats betwen SAP and STA -
 *			use ipa_get_wdi_sap_stats structure
 * @IPA_SET_WIFI_QUOTA: set quota limit on STA -
 *			use ipa_set_wifi_quota structure
 */
typedef __qdf_ipa_wdi_meter_evt_type_t qdf_ipa_wdi_meter_evt_type_t;

typedef __qdf_ipa_get_wdi_sap_stats_t qdf_ipa_get_wdi_sap_stats_t;

/**
 * qdf_ipa_set_wifi_quota_t - structure used for
 *                                   IPA_SET_WIFI_QUOTA.
 */
typedef __qdf_ipa_set_wifi_quota_t qdf_ipa_set_wifi_quota_t;

/**
 * qdf_ipa_connect_params_t - low-level client connect input parameters. Either
 * client allocates the data and desc FIFO and specifies that in data+desc OR
 * specifies sizes and pipe_mem pref and IPA does the allocation.
 */
typedef __qdf_ipa_connect_params_t qdf_ipa_connect_params_t;

/**
 * qdf_ipa_tx_meta_t - meta-data for the TX packet
 */
typedef __qdf_ipa_tx_meta_t qdf_ipa_tx_meta_t;

/**
 *  __qdf_ipa_sps_params_t - SPS related output parameters resulting from
 */
typedef __qdf_ipa_sps_params_t qdf_ipa_sps_params_t;

/**
 * qdf_ipa_tx_intf_t - interface tx properties
 */
typedef __qdf_ipa_tx_intf_t qdf_ipa_tx_intf_t;

/**
 * qdf_ipa_rx_intf_t - interface rx properties
 */
typedef __qdf_ipa_rx_intf_t qdf_ipa_rx_intf_t;

/**
 * qdf_ipa_ext_intf_t - interface ext properties
 */
typedef __qdf_ipa_ext_intf_t qdf_ipa_ext_intf_t;

/**
 * qdf_ipa_sys_connect_params_t - information needed to setup an IPA end-point
 * in system-BAM mode
 */
typedef __qdf_ipa_sys_connect_params_t qdf_ipa_sys_connect_params_t;

/**
 * __qdf_pa_rm_event_t - IPA RM events
 *
 * Indicate the resource state change
 */
typedef __qdf_ipa_rm_event_t qdf_ipa_rm_event_t;

/**
 * struct qdf_ipa_rm_register_params_t - information needed to
 *      register IPA RM client with IPA RM
 */
typedef __qdf_ipa_rm_register_params_t qdf_ipa_rm_register_params_t;

/**
 * struct qdf_ipa_rm_create_params_t - information needed to initialize
 *				the resource
 *
 * IPA RM client is expected to perform non blocking operations only
 * in request_resource and release_resource functions and
 * release notification context as soon as possible.
 */
typedef __qdf_ipa_rm_create_params_t qdf_ipa_rm_create_params_t;

/**
 * qdf_ipa_rm_perf_profile_t - information regarding IPA RM client performance
 * profile
 */
typedef __qdf_ipa_rm_perf_profile_t qdf_ipa_rm_perf_profile_t;

/**
 * qdf_ipa_tx_data_desc_t - information needed
 * to send data packet to HW link: link to data descriptors
 * priv: client specific private data
 */
typedef __qdf_ipa_tx_data_desc_t qdf_ipa_tx_data_desc_t;

/**
 * qdf_ipa_rx_data_t - information needed
 * to send to wlan driver on receiving data from ipa hw
 */
typedef __qdf_ipa_rx_data_t qdf_ipa_rx_data_t;

/**
 * qdf_ipa_wdi_ul_params_t - WDI_RX configuration
 */
typedef __qdf_ipa_wdi_ul_params_t qdf_ipa_wdi_ul_params_t;

/**
 * qdf_ipa_wdi_ul_params_smmu_t - WDI_RX configuration (with WLAN SMMU)
 */
typedef __qdf_ipa_wdi_ul_params_smmu_t qdf_ipa_wdi_ul_params_smmu_t;

/**
 * qdf_ipa_wdi_dl_params_t - WDI_TX configuration
 */
typedef __qdf_ipa_wdi_dl_params_t qdf_ipa_wdi_dl_params_t;

/**
 * qdf_ipa_wdi_dl_params_smmu_t - WDI_TX configuration (with WLAN SMMU)
 */
typedef __qdf_ipa_wdi_dl_params_smmu_t qdf_ipa_wdi_dl_params_smmu_t;

/**
 * qdf_ipa_wdi_in_params_t - information provided by WDI client
 */
typedef __qdf_ipa_wdi_in_params_t qdf_ipa_wdi_in_params_t;

/**
 * qdf_ipa_wdi_out_params_t - information provided to WDI client
 */
typedef __qdf_ipa_wdi_out_params_t qdf_ipa_wdi_out_params_t;

/**
 * qdf_ipa_wdi_db_params_t - information provided to retrieve
 *       physical address of uC doorbell
 */
typedef __qdf_ipa_wdi_db_params_t qdf_ipa_wdi_db_params_t;

/**
 * qdf_ipa_wdi_uc_ready_params_t - uC ready CB parameters
 */
typedef void (*qdf_ipa_uc_ready_cb)(void *priv);
typedef __qdf_ipa_wdi_uc_ready_params_t qdf_ipa_wdi_uc_ready_params_t;

/**
 * qdf_ipa_wdi_buffer_info_t - address info of a WLAN allocated buffer
 *
 * IPA driver will create/release IOMMU mapping in IPA SMMU from iova->pa
 */
typedef __qdf_ipa_wdi_buffer_info_t qdf_ipa_wdi_buffer_info_t;

/**
 * qdf_ipa_gsi_ep_config_t - IPA GSI endpoint configurations
 */
typedef __qdf_ipa_gsi_ep_config_t qdf_ipa_gsi_ep_config_t;

/**
 * qdf_ipa_dp_evt_type_t - type of event client callback is
 * invoked for on data path
 * @IPA_RECEIVE: data is struct sk_buff
 * @IPA_WRITE_DONE: data is struct sk_buff
 */
typedef __qdf_ipa_dp_evt_type_t qdf_ipa_dp_evt_type_t;

#ifdef WDI3_STATS_UPDATE
/**
 * qdf_ipa_wdi_tx_info_t - WLAN embedded TX bytes information
 *
 * WLAN host fills this structure to update IPA driver about
 * embedded TX information.
 */
typedef __qdf_ipa_wdi_tx_info_t qdf_ipa_wdi_tx_info_t;

/**
 * qdf_ipa_wdi_bw_info_t - BW threshold levels to be monitored
 * by IPA uC
 */
typedef __qdf_ipa_wdi_bw_info_t qdf_ipa_wdi_bw_info_t;

/**
 * qdf_ipa_inform_wlan_bw_t - BW information given by IPA driver
 * whenever uC detects threshold level reached
 */
typedef __qdf_ipa_inform_wlan_bw_t qdf_ipa_inform_wlan_bw_t;
#endif

typedef __qdf_ipa_hdr_add_t qdf_ipa_hdr_add_t;
typedef __qdf_ipa_hdr_del_t qdf_ipa_hdr_del_t;
typedef __qdf_ipa_ioc_add_hdr_t qdf_ipa_ioc_add_hdr_t;
typedef __qdf_ipa_ioc_del_hdr_t qdf_ipa_ioc_del_hdr_t;
typedef __qdf_ipa_ioc_get_hdr_t qdf_ipa_ioc_get_hdr_t;
typedef __qdf_ipa_ioc_copy_hdr_t qdf_ipa_ioc_copy_hdr_t;
typedef __qdf_ipa_ioc_add_hdr_proc_ctx_t qdf_ipa_ioc_add_hdr_proc_ctx_t;
typedef __qdf_ipa_ioc_del_hdr_proc_ctx_t qdf_ipa_ioc_del_hdr_proc_ctx_t;
typedef __qdf_ipa_msg_meta_t qdf_ipa_msg_meta_t;
typedef __qdf_ipa_client_type_t qdf_ipa_client_type_t;
typedef __qdf_ipa_hw_stats_wdi_info_data_t qdf_ipa_hw_stats_wdi_info_data_t;
typedef __qdf_ipa_rm_resource_name_t  qdf_ipa_rm_resource_name_t;
typedef __qdf_ipa_wlan_event_t qdf_ipa_wlan_event_t;
typedef __qdf_ipa_wlan_msg_t qdf_ipa_wlan_msg_t;
typedef __qdf_ipa_wlan_msg_ex_t qdf_ipa_wlan_msg_ex_t;
typedef __qdf_ipa_ioc_tx_intf_prop_t qdf_ipa_ioc_tx_intf_prop_t;
typedef __qdf_ipa_ioc_rx_intf_prop_t qdf_ipa_ioc_rx_intf_prop_t;
typedef __qdf_ipa_wlan_hdr_attrib_val_t qdf_ipa_wlan_hdr_attrib_val_t;
typedef int (*qdf_ipa_msg_pull_fn)(void *buff, u32 len, u32 type);
typedef void (*qdf_ipa_ready_cb)(void *user_data);

#define QDF_IPA_SET_META_MSG_TYPE(meta, msg_type) \
	__QDF_IPA_SET_META_MSG_TYPE(meta, msg_type)

#define QDF_IPA_RM_RESOURCE_GRANTED __QDF_IPA_RM_RESOURCE_GRANTED
#define QDF_IPA_RM_RESOURCE_RELEASED __QDF_IPA_RM_RESOURCE_RELEASED

#define QDF_IPA_VOLTAGE_LEVEL __QDF_IPA_VOLTAGE_LEVEL

#define QDF_IPA_RM_RESOURCE_WLAN_PROD __QDF_IPA_RM_RESOURCE_WLAN_PROD
#define QDF_IPA_RM_RESOURCE_WLAN_CONS __QDF_IPA_RM_RESOURCE_WLAN_CONS
#define QDF_IPA_RM_RESOURCE_APPS_CONS __QDF_IPA_RM_RESOURCE_APPS_CONS

#define QDF_IPA_CLIENT_WLAN1_PROD __QDF_IPA_CLIENT_WLAN1_PROD
#define QDF_IPA_CLIENT_WLAN3_PROD __QDF_IPA_CLIENT_WLAN3_PROD
#define QDF_IPA_CLIENT_WLAN1_CONS __QDF_IPA_CLIENT_WLAN1_CONS
#define QDF_IPA_CLIENT_WLAN2_CONS __QDF_IPA_CLIENT_WLAN2_CONS
#define QDF_IPA_CLIENT_WLAN3_CONS __QDF_IPA_CLIENT_WLAN3_CONS
#define QDF_IPA_CLIENT_WLAN4_CONS __QDF_IPA_CLIENT_WLAN4_CONS
#define QDF_IPA_CLIENT_WLAN4_PROD __QDF_IPA_CLIENT_WLAN4_PROD
#ifdef FEATURE_IPA_PIPE_CHANGE_WDI1
#define QDF_IPA_CLIENT_WLAN_LEGACY_CONS   QDF_IPA_CLIENT_WLAN3_CONS
#define QDF_IPA_CLIENT_WLAN_LEGACY_PROD   QDF_IPA_CLIENT_WLAN3_PROD
#define QDF_IPA_CLIENT_MCC2_CONS          QDF_IPA_CLIENT_WLAN4_CONS
#else
#define QDF_IPA_CLIENT_WLAN_LEGACY_CONS   QDF_IPA_CLIENT_WLAN1_CONS
#define QDF_IPA_CLIENT_WLAN_LEGACY_PROD   QDF_IPA_CLIENT_WLAN1_PROD
#define QDF_IPA_CLIENT_MCC2_CONS          QDF_IPA_CLIENT_WLAN3_CONS
#endif

#ifdef QCN7605_SUPPORT
#define QDF_IPA_CLIENT_WLAN_WDI2_CONS __QDF_IPA_CLIENT_WLAN_WDI2_CONS
#define QDF_IPA_CLIENT_WLAN_WDI2_PROD __QDF_IPA_CLIENT_WLAN_WDI2_PROD
#else
#define QDF_IPA_CLIENT_WLAN_WDI2_CONS QDF_IPA_CLIENT_WLAN1_CONS
#define QDF_IPA_CLIENT_WLAN_WDI2_PROD QDF_IPA_CLIENT_WLAN1_PROD
#endif

/*
 * Resume / Suspend
 */

static inline void qdf_ipa_free_skb(qdf_ipa_rx_data_t *rx_in)
{
	return __qdf_ipa_free_skb(rx_in);
}

static inline int qdf_ipa_uc_reg_rdyCB(
	qdf_ipa_wdi_uc_ready_params_t *param)
{
	return __qdf_ipa_uc_reg_rdyCB(param);
}

static inline int qdf_ipa_uc_dereg_rdyCB(void)
{
	return __qdf_ipa_uc_dereg_rdyCB();
}

static inline int qdf_ipa_get_wdi_stats(qdf_ipa_hw_stats_wdi_info_data_t *stats)
{
	return __qdf_ipa_get_wdi_stats(stats);
}

static inline int qdf_ipa_register_ipa_ready_cb(
	void (*qdf_ipa_ready_cb)(void *user_data),
	void *user_data)
{
	return __qdf_ipa_register_ipa_ready_cb(qdf_ipa_ready_cb, user_data);
}

static inline int qdf_ipa_setup_sys_pipe(qdf_ipa_sys_connect_params_t *sys_in,
					 u32 *clnt_hdl)
{
	return __qdf_ipa_setup_sys_pipe(sys_in, clnt_hdl);
}

static inline int qdf_ipa_teardown_sys_pipe(u32 clnt_hdl)
{
	return __qdf_ipa_teardown_sys_pipe(clnt_hdl);
}

/*
 * Messaging
 */
static inline int qdf_ipa_send_msg(qdf_ipa_msg_meta_t *meta, void *buff,
				   ipa_msg_free_fn callback)
{
	return __qdf_ipa_send_msg(meta, buff, callback);
}

static inline bool qdf_ipa_is_ready(void)
{
	return __qdf_ipa_is_ready();
}

#ifdef FEATURE_METERING
static inline int qdf_ipa_broadcast_wdi_quota_reach_ind(uint32_t index,
							uint64_t quota_bytes)
{
	return __qdf_ipa_broadcast_wdi_quota_reach_ind(index, quota_bytes);
}
#endif

#ifdef ENABLE_SMMU_S1_TRANSLATION
/**
 * qdf_get_ipa_smmu_enabled() - to get IPA SMMU enable status
 *
 * Return: true when IPA SMMU enabled, otherwise false
 */
static inline bool qdf_get_ipa_smmu_enabled(void)
{
	return __qdf_get_ipa_smmu_enabled();
}
#endif

#ifdef IPA_LAN_RX_NAPI_SUPPORT
/**
 * qdf_ipa_get_lan_rx_napi() - Check if NAPI is enabled in LAN
 * RX DP
 *
 * Returns: true if enabled, false otherwise
 */
static inline bool qdf_ipa_get_lan_rx_napi(void)
{
	return __qdf_ipa_get_lan_rx_napi();
}
#else
static inline bool qdf_ipa_get_lan_rx_napi(void)
{
	return false;
}
#endif /* IPA_LAN_RX_NAPI_SUPPORT */
#endif /* IPA_OFFLOAD */
#endif /* _QDF_IPA_H */
