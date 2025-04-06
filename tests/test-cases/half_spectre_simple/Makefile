all: gadget
.PHONY: clean

gadget: gadget.s
	gcc -g -O0 -c gadget.s -o gadget

clean:
	rm -f -r gadget output asm gadgets.csv gadgets-reasoned.csv
