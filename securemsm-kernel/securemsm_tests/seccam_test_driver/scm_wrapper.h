/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
 */

/*
 * Context Switch Performance Test
 */

#ifndef _LINUX_SCM_WRAPPER_H_
#define _LINUX_SCM_WRAPPER_H_


#include <linux/firmware/qcom/qcom_scm.h>
#include <linux/ITrustedCameraDriver.h>
#include <linux/CTrustedCameraDriver.h>

inline bool qcom_scm_is_mode_switch_available_wrapper(void)
{
	return qcom_scm_is_mode_switch_available();
}

inline int qcom_scm_config_cpu_errata_wrapper(void)
{
	return qcom_scm_config_cpu_errata();
}

inline bool qcom_scm_is_secure_wdog_trigger_available_wrapper(void)
{
	return qcom_scm_is_secure_wdog_trigger_available();
}

inline int qcom_scm_camera_protect_all_wrapper(uint32_t protect, uint32_t param)
{
	return qcom_scm_camera_protect_all(protect, param);
}

inline int qcom_scm_camera_protect_phy_lanes_wrapper(uint32_t protect,
		uint32_t param)
{
	return qcom_scm_camera_protect_phy_lanes(protect, param);
}

inline int qcom_smc_cam_protect(struct Object me, uint32_t protect,
		uint32_t phy_param, uint32_t csid_param, uint32_t cdm_param)
{
	ITCDriverSensorInfo *phy_sel_info =
		kmalloc(sizeof(ITCDriverSensorInfo), GFP_KERNEL);

	if (phy_sel_info == NULL)
		return -ENOMEM;
	phy_sel_info->protect = protect;
	phy_sel_info->phy_lane_sel_mask = phy_param;
	phy_sel_info->csid_hw_idx_mask = csid_param;
	phy_sel_info->cdm_hw_idx_mask = cdm_param;

	return ITrustedCameraDriver_dynamicProtectSensor(me, phy_sel_info);
}

inline int qcom_smc_config_fd_port(struct Object me, uint32_t protect)
{
	return ITrustedCameraDriver_dynamicConfigureFDPort(me, protect);
}

inline int qcom_smc_get_version(struct Object me, uint32_t *arch_ver,
		uint32_t *max_ver, uint32_t *min_ver)
{
	return ITrustedCameraDriver_getVersion(me, arch_ver, max_ver, min_ver);
}

inline int qcom_smc_dynamic_config_port(struct Object me, uint32_t hw_type,
		uint32_t hw_id_mask, uint32_t protect_port, uint32_t phy_id,
		uint32_t num_ports, uint32_t port_id, size_t port_info_len)
{
	struct PortInfo *port_info_ptr = kmalloc(sizeof(struct PortInfo), GFP_KERNEL);

	if (port_info_ptr == NULL)
		return -ENOMEM;
	port_info_ptr->hw_type = hw_type;
	port_info_ptr->hw_id_mask = hw_id_mask;
	port_info_ptr->protect = protect_port;
	port_info_ptr->phy_id = phy_id;
	port_info_ptr->num_ports = num_ports;
	port_info_ptr->port_id[0] = port_id;

	return ITrustedCameraDriver_dynamicConfigurePortsV2(me,
			port_info_ptr, port_info_len);
}

#endif
