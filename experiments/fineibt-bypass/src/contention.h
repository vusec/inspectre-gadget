#ifndef _CONTENTION_H_
#define _CONTENTION_H_

#define _GNU_SOURCE

#include <stdio.h>
#include <sched.h>

#include "../../poc-common/common.h"
#include "targets.h"

extern void option1_2_5();
extern void option2_1_9();
extern void option3_2_8();
extern void option_4_0();

static void pin_to_core(int core) {
    cpu_set_t mask;

    CPU_ZERO(&mask);
    CPU_SET(core, &mask);

    if (sched_setaffinity(0, sizeof(cpu_set_t), &mask) == -1) {
        perror("sched_setaffinity");
        assert(0);
    }
}


static void * start_contention(void * arg)
{

    pin_to_core(CORE_CONTENTION);

    uint64_t option = 2;

    printf("Creating contention on core %d\n", CORE_CONTENTION);
    printf("Contention: ");

    switch (option)
    {
    case 1:
        printf("Option 1 (2 outer 5 inner)\n");
        option1_2_5();
        break;
    case 2:
        printf("Option 2 (1 outer 9 inner)\n");
        option2_1_9();
        break;
    case 3:
        printf("Option 3 (2 outer 8 inner)\n");
        option3_2_8();
        break;
    case 4:
        printf("Option 4 (only 8 je)\n");
        option_4_0();
        break;
    default:
        break;
    }

}

#endif //_CONTENTION_H_
