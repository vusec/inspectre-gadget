CFLAGS = -g -O3 -Wno-unused-function -lrt -lm -lpthread -no-pie

ARCH = undef
OS = undef


all: main
.PHONY: clean

main: main.c
	gcc-9 -lm -o $@ main.c flush_and_reload.c workload.S $(CFLAGS) -D$(ARCH) -D$(OS)

clean:
	rm -f main snippet.o

