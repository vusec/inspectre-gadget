CFLAGS = -g -O3 -Wno-unused-function

all: do_kaslr_prefetch
.PHONY: clean

ARCH = undef

prefetch: prefetch.c
	gcc  -o $@ prefetch.c kaslr_prefetch.c $(CFLAGS) -D$(ARCH) -DVERBOSE

do_kaslr_prefetch: do_kaslr_prefetch.c
	gcc  -o $@ do_kaslr_prefetch.c kaslr_prefetch.c $(CFLAGS) -D$(ARCH) -DVERBOSE

clean:
	rm -f prefetch do_kaslr_prefetch
