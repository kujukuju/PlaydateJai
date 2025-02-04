detected_OS := $(shell uname -s)
detected_OS := $(strip $(detected_OS))

$(info detected_OS is "$(detected_OS)")

ifeq ($(detected_OS), Linux)

  GCCFLAGS = -g
  SIMCOMPILER = gcc $(GCCFLAGS)
  DYLIB_FLAGS = -shared -fPIC
  DYLIB_EXT = so
  PDCFLAGS = -sdkpath $(SDK)
endif

ifeq ($(detected_OS), Darwin)

  CLANGFLAGS = -g
  SIMCOMPILER = clang $(CLANGFLAGS)
  DYLIB_FLAGS = -dynamiclib -rdynamic
  DYLIB_EXT = dylib
  PDCFLAGS=
  # Uncomment to build a binary that works with Address Sanitizer
  #CLANGFLAGS += -fsanitize=address

endif

TRGT = arm-none-eabi-
GCC:=$(dir $(shell which $(TRGT)gcc))

ifeq ($(GCC),)
GCC = /usr/local/bin/
endif

OJBCPY:=$(dir $(shell which $(TRGT)objcopy))

ifeq ($(OJBCPY),)
OJBCPY = /usr/local/bin/
endif

PDC = $(SDK)/bin/pdc

VPATH += $(SDK)/C_API/buildsupport

CC   = $(GCC)$(TRGT)gcc -g3
CP   = $(OJBCPY)$(TRGT)objcopy
AS   = $(GCC)$(TRGT)gcc -x assembler-with-cpp
STRIP= $(GCC)$(TRGT)strip
BIN  = $(CP) -O binary
HEX  = $(CP) -O ihex

MCU  = cortex-m7

# List all default C defines here, like -D_DEBUG=1
DDEFS = -DTARGET_PLAYDATE=1 -DTARGET_EXTENSION=1

# List all default directories to look for include files here
DINCDIR = . $(SDK)/C_API

# List all default ASM defines here, like -D_DEBUG=1
DADEFS =

# List the default directory to look for the libraries here
DLIBDIR =

# List all default libraries here
DLIBS =

OPT = -O2 -falign-functions=16 -fomit-frame-pointer

#
# Define linker script file here
#
LDSCRIPT = $(patsubst ~%,$(HOME)%,$(SDK)/C_API/buildsupport/link_map.ld)

#
# Define FPU settings here
#
FPU = -mfloat-abi=hard -mfpu=fpv5-sp-d16 -D__FPU_USED=1

INCDIR  = $(patsubst %,-I %,$(DINCDIR) $(UINCDIR))
LIBDIR  = $(patsubst %,-L %,$(DLIBDIR) $(ULIBDIR))
OBJDIR  = build
DEPDIR  = $(OBJDIR)/dep

DEFS	= $(DDEFS) $(UDEFS)

ADEFS   = $(DADEFS) $(UADEFS) -D__HEAP_SIZE=$(HEAP_SIZE) -D__STACK_SIZE=$(STACK_SIZE)

SRC += $(SDK)/C_API/buildsupport/setup.c

# Original object list
_OBJS	= $(SRC:.c=.o)

# oject list in build folder
OBJS    = $(addprefix $(OBJDIR)/, $(_OBJS))

LIBS	= $(DLIBS) $(ULIBS)
MCFLAGS = -mthumb -mcpu=$(MCU) $(FPU)

ASFLAGS  = $(MCFLAGS) $(OPT) -g3 -gdwarf-2 -Wa,-amhls=$(<:.s=.lst) $(ADEFS)

CPFLAGS  = $(MCFLAGS) $(OPT) -gdwarf-2 -Wall -Wno-unused -Wstrict-prototypes -Wno-unknown-pragmas -fverbose-asm -Wdouble-promotion -mword-relocations -fno-common
CPFLAGS += -ffunction-sections -fdata-sections -Wa,-ahlms=$(OBJDIR)/$(notdir $(<:.c=.lst)) $(DEFS)

LDFLAGS  = -nostartfiles $(MCFLAGS) -T$(LDSCRIPT) -Wl,-Map=$(OBJDIR)/pdex.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs $(LIBDIR)

# Generate dependency information
CPFLAGS += -MD -MP -MF $(DEPDIR)/$(@F).d

#
# makefile rules
#

all: device_bin simulator_bin
	$(PDC) $(PDCFLAGS) Source $(PRODUCT)

debug: OPT = -O0
debug: all

print-%  : ; @echo $* = $($*)

MKOBJDIR:
	mkdir -p $(OBJDIR)

MKDEPDIR:
	mkdir -p $(DEPDIR)

device: device_bin
	$(PDC) $(PDCFLAGS) Source $(PRODUCT)

simulator: simulator_bin
	$(PDC) $(PDCFLAGS) Source $(PRODUCT)

device_bin: $(OBJDIR)/pdex.elf
	cp $(OBJDIR)/pdex.elf Source

simulator_bin: $(OBJDIR)/pdex.${DYLIB_EXT}
	cp $(OBJDIR)/pdex.${DYLIB_EXT} Source

# pdc is deprecated but in the old docs, alias to simulator
pdc: simulator

# for external builds (Xcode)
pdx:
	$(PDC) $(PDCFLAGS) Source $(PRODUCT)

$(OBJDIR)/%.o : %.c | MKOBJDIR MKDEPDIR
	mkdir -p `dirname $@`
	$(CC) -c $(CPFLAGS) -I . $(INCDIR) $< -o $@

$(OBJDIR)/%.o : %.s | MKOBJDIR MKDEPDIR
	$(AS) -c $(ASFLAGS) $< -o $@

.PRECIOUS: $(OBJDIR)/%elf
.PRECIOUS: $(OBJDIR)/%bin
.PRECIOUS: $(OBJDIR)/%hex
$(OBJDIR)/pdex.elf: $(OBJS) $(LDSCRIPT)
	$(CC) $(OBJS) $(LDFLAGS) $(LIBS) -o $@

$(OBJDIR)/pdex.hex: $(OBJDIR)/pdex.elf
	$(HEX) $< $@

$(OBJDIR)/pdex.bin: $(OBJDIR)/pdex.elf
	$(BIN) $< $@

$(OBJDIR)/pdex.${DYLIB_EXT}: $(SRC) | MKOBJDIR
	$(SIMCOMPILER) $(DYLIB_FLAGS) -lm -DTARGET_SIMULATOR=1 -DTARGET_EXTENSION=1 $(INCDIR) -o $(OBJDIR)/pdex.${DYLIB_EXT} $(SRC)

clean:
	-rm -rf $(OBJDIR)
	-rm -fR $(PRODUCT)
	-rm -fR Source/pdex.bin
	-rm -fR Source/pdex.dylib
	-rm -fR Source/pdex.so
	-rm -fR Source/pdex.dll
	-rm -fR Source/pdex.elf
#
# Include the dependency files, should be the last of the makefile
#
-include $(wildcard $(DEPDIR)/*)

# *** EOF ***
