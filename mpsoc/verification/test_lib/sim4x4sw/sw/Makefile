SUBDIRS := $(wildcard */.)
all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS) 
    
clean:
	$(MAKE) -C $(CODE_DIR) clean    
