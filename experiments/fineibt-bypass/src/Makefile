CFLAGS = -g -O3 -Wno-unused-function -lrt -lm -lpthread  -no-pie

ARCH = undef
OS = undef

LIB = ../../poc-common

all: main
.PHONY: clean

main: main.c
	gcc -c snippet.S -o snippet.o
	gcc -o $@ main.c flush_and_reload.c colliding_bhb.c evict_pht.c snippet.o workload.S ${LIB}/kaslr_prefetch/kaslr_prefetch.c $(CFLAGS) -D$(ARCH) -D$(OS)

clean:
	rm -f main snippet.o

