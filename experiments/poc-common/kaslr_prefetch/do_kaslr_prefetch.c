/*
 * Friday, October 27th 2023
 *
 * Sander Wiebing - s.j.wiebing@vu.nl
 * Alvise de Faveri Tron - a.de.faveri.tron@vu.nl
 * Herbert Bos - herbertb@cs.vu.nl
 * Cristiano Giuffrida - giuffrida@cs.vu.nl
 *
 * Vrije Universiteit Amsterdam - Amsterdam, The Netherlands
 *
 */

#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <time.h>
#include <stdio.h>
#include <assert.h>

#include "kaslr_prefetch.h"

#define PHYS_MAP_START 0xffff800000000000
#define PHYS_MAP_END   0xffffc87fffffffff
#define PHYS_ALIGNMENT 1 << 30 // 1 GB

#define TEXT_START 0xffffffff80000000
#define TEXT_END   0xffffffffc0000000
#define TEXT_ALIGNMENT (1 << 21) // 2 MB

int main(int argc, char **argv)
{
    uint8_t * start;

    srand(time(0));
    initialize_kaslr_prefetch();


    start = (uint8_t *) find_section_start(TEXT_START, TEXT_END, TEXT_ALIGNMENT);

    if (start == 0) {
        printf("Finding .text section failed\n");
    } else {
        printf("\t%10s: %p\n", ".text", start);
    }

    start = (uint8_t *) find_section_start(PHYS_MAP_START, PHYS_MAP_END, PHYS_ALIGNMENT);

    if (start == 0) {
        printf("Finding phys_map section failed\n");
    } else {
        printf("\t%10s: %p\n", "phys_map",start);
    }

}
