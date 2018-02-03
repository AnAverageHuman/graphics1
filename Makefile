OUTFILE ?= image.ppm
MAXCOLOR ?= 255

CLEANTARGETS := $(OUTFILE)
SHELL := bash

# Disable built-in rules and variables
MAKEFLAGS += -rR --no-print-directory

# We encode items into itemized lists because Make has no arithmetic system.
encode = $(shell for ((i = 1; i <= $1; i++)); do echo $$i; done)
decode = $(words $1)

LB ?= 500
HB ?= 1000
RANDINB := $$((RANDOM % $$(($(HB) - $(LB))) + $(LB) + 1))
DIMR := $(call encode,$(shell echo $(RANDINB)))
DIMC := $(call encode,$(shell echo $(RANDINB)))

# echo all commands if $V is set; replacing echo commands with "true"
ifneq ($(V),)
	SHELL += -x
	Q = true ||
endif

.PHONY: all clean row $(DIMR)

all: clean header $(OUTFILE)

clean:
	@$(foreach i, $(CLEANTARGETS), $(Q)echo "  CLEAN		$(i)"; rm -rf $(i);)

color := $$((RANDOM % $(MAXCOLOR)))

pixel := $(color) $(color) $(color)

# Avoid a race condition when running in parallel by waiting for clean.
header: clean
	@$(Q)echo "  MAGICNUMBER	P3"
	@echo "P3" >> $(OUTFILE)

	@$(Q)echo "  ROWS		$(call decode, $(DIMR))"
	@echo "$(call decode, $(DIMR))" >> $(OUTFILE)

	@$(Q)echo "  COLUMNS	$(call decode, $(DIMC))"
	@echo "$(call decode, $(DIMC))" >> $(OUTFILE)

	@$(Q)echo "  COLORSPACE	$(MAXCOLOR)"
	@echo "$(MAXCOLOR)" >> $(OUTFILE)

row:
	@$(foreach x, $(DIMC), $(shell echo "$(pixel) " >> $(OUTFILE)))
	@echo >> $(OUTFILE)

$(OUTFILE): $(DIMR)
	@$(Q)echo "  FINISHED	$(OUTFILE)"

# Avoid a race condition when running in parallel by waiting for the header.
$(DIMR): header
	@$(Q)echo "  ROW		$@"
	@+$(MAKE) row

