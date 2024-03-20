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

#include<linux/module.h>
#include<linux/kernel.h>
#include<asm/pgtable_types.h>
#include<asm/pgtable_64_types.h>
#include<asm/page.h>
#include<linux/string.h>
#include<linux/proc_fs.h>
#include <linux/pgtable.h>


// je +5
// ud2
// nop
#define SID_FINE_IBT_BYTES "\x74\x03\x0f\x0b\x90"

// jmp +5
// ud2
// nop
#define SID_PATCHED_BYTES "\xeb\x03\x0f\x0b\x90"

#define JE_BYTE 0x74
#define JMP_BYTE 0xeb

MODULE_AUTHOR("Sander Wiebing");
MODULE_DESCRIPTION("Patch FineIBT SID");
MODULE_LICENSE("GPL");

unsigned long *get_pte(void *virt_addr)
{
	#define HUGEPAGE_SIZE (1ULL << 21)
	#define PAGE_WRITABLE (1 << 1)
	unsigned long va = (unsigned long)virt_addr;
	unsigned long *r = NULL;
	pgd_t *pgd;
	p4d_t *p4d;
	pud_t *pud;
	pmd_t *pmd;
	pte_t *pte;

	pgd = pgd_offset(current->mm, va);
	if (pgd_none(*pgd) || pgd_bad(*pgd))
		return NULL;

	p4d = p4d_offset(pgd, va);
	if (p4d_none(*p4d) || p4d_bad(*p4d))
		return NULL;

	pud = pud_offset(p4d, va);
	if (pud_none(*pud))
		return NULL;
	if (pud_bad(*pud))
		return NULL;

	pmd = pmd_offset(pud, va);
	if (pmd_none(*pmd))
		return NULL;
	if (pmd_trans_huge(*pmd)) {
		return (unsigned long *)pmd;
	}
	if (pmd_bad(*pmd))
		return NULL;

	pte = pte_offset_kernel(pmd, va);
	if (!pte_none(*pte)) {
		r = (unsigned long *)pte;
	}
	pte_unmap(pte);

	return r;
}


static void write_byte_at_address(uint8_t * vaddr, uint8_t byte) {

    unsigned long *pte_start, pte_start_val;

	// Make the page that we want to write to writable.
	pte_start = get_pte(vaddr);
	pte_start_val = *pte_start;
	*pte_start |= PAGE_WRITABLE;


    // Write the byte

    memcpy(vaddr, &byte, 1);


	// Restore the old page access rights.
    *pte_start = pte_start_val;

    pr_info("Write successful\n");


}

static ssize_t mod_remove_fine_ibt_check(struct file *filp, const char *buf, size_t len, loff_t *off) {

    char kbuf[256];
    uint8_t * function_address;
    char sid_check[5];
    uint64_t value;


    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }


    if (sscanf(kbuf, "%llx", (uint64_t *) &function_address) != 1) {
        return -EFAULT;
    }


    if(!virt_addr_valid(function_address)) {
        pr_info("ERROR: Function address is invalid (%px)\n", function_address);
        return -EFAULT;
    }

    if (get_kernel_nofault(value, (uint64_t *) function_address)) {
        pr_info("ERROR: Function address is not mapped (%px)\n", function_address);
        return -EFAULT;
    }

    pr_info("Function address: %px\n", function_address);

    // check if a IBT check is in place

    memcpy(sid_check, function_address - 0x5, 5);

    pr_info("SID CHECK bytes: %02x %02x %02x %02x %02x\n", sid_check[0],
        sid_check[1], sid_check[2], sid_check[3], sid_check[4]);

    if (strncmp(sid_check, SID_FINE_IBT_BYTES, 5) != 0) {
        pr_info("ERROR: Incorrect SID bytes\n");
        return -EFAULT;
    }

    write_byte_at_address(function_address - 0x5, JMP_BYTE);



    len = strlen(kbuf);
    *off += len;


    return len;

}

static ssize_t mod_insert_fine_ibt_check(struct file *filp, const char *buf, size_t len, loff_t *off) {

    char kbuf[256];
    uint8_t * function_address;
    char sid_check[6];
    uint64_t value;


    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }


    if (sscanf(kbuf, "%llx", (uint64_t *) &function_address) != 1) {
        return -EFAULT;
    }


    if(!virt_addr_valid(function_address)) {
        pr_info("ERROR: Function address is invalid (%px)\n", function_address);
        return -EFAULT;
    }

    if (get_kernel_nofault(value, (uint64_t *) function_address)) {
        pr_info("ERROR: Function address is not mapped (%px)\n", function_address);
        return -EFAULT;
    }

    pr_info("Function address: %px\n", function_address);

    // check if a IBT check is in place

    memcpy(sid_check, function_address - 0x5, 5);
    sid_check[5] = '\x0';

    pr_info("SID CHECK bytes: %02x %02x %02x %02x %02x\n", sid_check[0],
        sid_check[1], sid_check[2], sid_check[3], sid_check[4]);

    if (strcmp(sid_check, SID_PATCHED_BYTES) != 0) {
        pr_info("ERROR: Incorrect SID bytes\n");
        return -EFAULT;
    }

    write_byte_at_address(function_address - 0x5, JE_BYTE);



    len = strlen(kbuf);
    *off += len;


    return len;

}

static ssize_t mod_switch_fine_ibt_check(struct file *filp, const char *buf, size_t len, loff_t *off) {

    char kbuf[256];
    uint8_t * function_address;
    char sid_check[6];
    uint64_t value;
    uint8_t to_write;


    memset(kbuf, 0, 256);

    if (copy_from_user(kbuf, buf, min(len, (size_t) 255))) {
		return -EFAULT;
    }


    if (sscanf(kbuf, "%llx", (uint64_t *) &function_address) != 1) {
        return -EFAULT;
    }


    if(!virt_addr_valid(function_address)) {
        pr_info("ERROR: Function address is invalid (%px)\n", function_address);
        return -EFAULT;
    }

    if (get_kernel_nofault(value, (uint64_t *) function_address)) {
        pr_info("ERROR: Function address is not mapped (%px)\n", function_address);
        return -EFAULT;
    }

    pr_info("Function address: %px\n", function_address);

    // check if a IBT check is in place

    memcpy(sid_check, function_address - 0x5, 5);
    sid_check[5] = '\x0';

    pr_info("SID CHECK bytes: %02x %02x %02x %02x %02x\n", sid_check[0],
        sid_check[1], sid_check[2], sid_check[3], sid_check[4]);


    if (strcmp(sid_check, SID_FINE_IBT_BYTES) == 0) {
        to_write = JMP_BYTE;
        pr_info("Disabling SID check...\n");

    } else if (strcmp(sid_check, SID_PATCHED_BYTES) == 0) {
        to_write = JE_BYTE;
        pr_info("Enabling SID check...\n");

    } else {
        pr_info("ERROR: Incorrect SID bytes\n");
        return -EFAULT;
    }


    write_byte_at_address(function_address - 0x5, to_write);


    len = strlen(kbuf);
    *off += len;


    return len;

}



static struct proc_ops remove_fine_ibt_check_fops = {
	.proc_write = mod_remove_fine_ibt_check
};

static struct proc_ops insert_fine_ibt_check_fops = {
	.proc_write = mod_insert_fine_ibt_check
};

static struct proc_ops switch_fine_ibt_check_fops = {
	.proc_write = mod_switch_fine_ibt_check
};



static struct proc_dir_entry *proc_dir;

static int __init native_bhi_init(void)
{

	pr_info("initializing\n");

	proc_dir = proc_mkdir("patch_kernel", NULL);
	proc_create("remove_fine_ibt_check", 0666, proc_dir, &remove_fine_ibt_check_fops);
    proc_create("insert_fine_ibt_check", 0666, proc_dir, &insert_fine_ibt_check_fops);
    proc_create("switch_fine_ibt_check", 0666, proc_dir, &switch_fine_ibt_check_fops);


	return 0;
}

static void __exit native_bhi_exit(void)
{
	pr_info("exiting\n");

	proc_remove(proc_dir);
}

module_init(native_bhi_init);
module_exit(native_bhi_exit);
