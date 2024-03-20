obj-m += patch_kernel_module.o

patch_kernel_module-objs := patch-kernel.o


all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
