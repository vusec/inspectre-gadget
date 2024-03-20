obj-m += ibt_testing_module.o

ibt_testing_module-objs := ibt_testing.o ./snippets/leak_gadget.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
