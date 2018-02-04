OUTFILE ?= image.ppm
MAXCOLOR ?= 255

OBJDIR := build
CLEANTARGETS := $(OBJDIR) $(OUTFILE)
SHELL := bash

# Disable built-in rules and variables
MAKEFLAGS += -rR --no-print-directory

# We encode items into itemized lists because Make has no arithmetic system.
encode = $(shell for ((i = 1; i <= $1; i++)); do echo $$i; done)
decode = $(words $1)

LB ?= 500
HB ?= 1000
RLB ?= $(LB)
RHB ?= $(HB)
CLB ?= $(LB)
CHB ?= $(HB)

RANDINB = $(shell echo $$((RANDOM % $$(($1 - $2)) + $2 + 1))) # HB, LB
DIMR := $(addprefix $(OBJDIR)/, $(call encode,$(call RANDINB, $(RHB), $(RLB))))
DIMC := $(addprefix $(OBJDIR)/, $(call encode,$(call RANDINB, $(CHB), $(CLB))))

# echo all commands if $V is set; replacing echo commands with "true"
ifneq ($(V),)
	SHELL += -x
	Q = true ||
endif

.PHONY: all clean distclean prepare
.INTERMEDIATE: $(OBJDIR)/header

all: $(OUTFILE)

clean:
	rm -f $(OUTFILE)

distclean:
	@$(foreach i, $(CLEANTARGETS), $(Q)echo "  CLEAN		$(i)"; rm -rf $(i);)

color := $$((RANDOM % $(MAXCOLOR)))

pixel := $(color) $(color) $(color)

prepare: distclean
	@$(Q)echo "  MKDIR		$(OBJDIR)"
	@mkdir -p $(OBJDIR)

$(OBJDIR)/header: prepare
	@$(Q)echo "  MAGICNUMBER	P3"
	@echo "P3" >> $@

	@$(Q)echo "  ROWS		$(call decode, $(DIMR))"
	@echo "$(call decode, $(DIMR))" >> $@

	@$(Q)echo "  COLUMNS	$(call decode, $(DIMC))"
	@echo "$(call decode, $(DIMC))" >> $@

	@$(Q)echo "  COLORSPACE	$(MAXCOLOR)"
	@echo "$(MAXCOLOR)" >> $@

$(DIMR): prepare
	@$(Q)echo "  ROW		$@"
	@$(foreach x, $(DIMC), $(shell echo "$(pixel) " >> $@))
	@echo >> $@

$(OUTFILE): $(OBJDIR)/header $(DIMR)
	@$(Q)echo "  PPM		$(OUTFILE)"
	@cat $^ >> $(OUTFILE)

