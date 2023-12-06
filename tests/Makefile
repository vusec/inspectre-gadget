SUBDIRS := $(wildcard ./*/.)
.PHONY: all $(SUBDIRS)

all:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done \

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) clean -C $$dir; \
	done
