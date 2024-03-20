/*
 * Tuesday, May 16th 2023
 *
 * Sander Wiebing - s.j.wiebing@student.vu.nl
 * Alvise de Faveri Tron - a.de.faveri.tron@vu.nl
 * Herbert Bos - herbertb@cs.vu.nl
 * Cristiano Giuffrida - giuffrida@cs.vu.nl
 *
 * Vrije Universiteit Amsterdam - Amsterdam, The Netherlands
 *
 */

#ifndef _COLLIDING_BHB_H_
#define _COLLIDING_BHB_H_

#include <unistd.h>

#include "flush_and_reload.h"

int find_colliding_history(struct config * cfg);
int find_hp_kern_address(struct config * cfg, uint64_t only_honey_pages);

#endif //_COLLIDING_BHB_H_
