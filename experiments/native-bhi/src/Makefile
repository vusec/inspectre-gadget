CFLAGS = -g -O3 -Wno-unused-function -lm

ARCH = undef
OS = undef

LIB = ../../poc-common

all: main
.PHONY: clean

main: main.c
	gcc -c snippet.S -o snippet.o
	gcc -o $@ main.c flush_and_reload.c colliding_bhb.c ${LIB}/kaslr_prefetch/kaslr_prefetch.c ${LIB}/l2_eviction/evict_sys_table_l2.c snippet.o $(CFLAGS) -D$(ARCH) -D$(OS)

clean:
	rm -f main snippet.o

