/* SPDX-License-Identifier: GPL-2.0-only */
#ifndef _CAM_GPIO618_H_
#define _CAM_GPIO618_H_

#include <linux/version.h>

/*
 * 6.17 removed struct gpio along with gpio_request_array(). The camera
 * driver still describes its GPIO tables with it and requests them one by
 * one with gpio_request_one(), which remains.
 */
struct gpio {
	unsigned int gpio;
	unsigned long flags;
	const char *label;
};

#endif /* _CAM_GPIO618_H_ */
