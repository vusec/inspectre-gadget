#ifndef _CONTENTION_H_
#define _CONTENTION_H_

#define _GNU_SOURCE

#include <stdio.h>
#include <unistd.h>

#include "common.h"
#include "targets.h"

extern void option1_2_5();
extern void option2_1_9();
extern void option3_2_8();
extern void option_4_0();


static void * start_contention(void * arg)
{

    pin_to_core(CORE_CONTENTION);

    uint64_t option = (uint64_t) arg;

    printf("Contention: ");

    switch (option)
    {
    case 1:
        printf("Option 1 (2 outer 5 inner)\n");
        usleep(1000);
	option1_2_5();
        break;
    case 2:
        printf("Option 2 (1 outer 9 inner)\n");
        usleep(1000);
	option2_1_9();
        break;
    case 3:
        printf("Option 3 (2 outer 8 inner)\n");
        usleep(1000);
	option3_2_8();
        break;
    case 4:
        printf("Option 4 (only 8 je)\n");
        usleep(1000);
	option_4_0();
        break;
    default:
        break;
    }

}

#endif //_CONTENTION_H_
