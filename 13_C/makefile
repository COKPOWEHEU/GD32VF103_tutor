progname := firmware
progdir := res
files := main startup

srcdir := src
builddir := build
libdir := lib

CROSS_COMPILE=riscv64-unknown-elf-
CC=$(CROSS_COMPILE)gcc
AS=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump
SIZE=$(CROSS_COMPILE)size

COMMON  = -MD -MP -MT $(builddir)/$(*F).o -MF $(builddir)/dep/$(@F).mk
COMMON += -march=rv32imac -mabi=ilp32 -mcmodel=medany 
ASMFLAGS = $(COMMON)
CFLAGS=$(COMMON)
CFLAGS+=-Wall -Os -g -Wno-main -Wstack-usage=400 -ffreestanding -Wno-unused -nostdlib
CFLAGS+=-fno-builtin-printf
CFLAGS+=-I$(libdir)/Firmware/GD32VF103_standard_peripheral/Include
CFLAGS+=-I$(libdir)/Firmware/GD32VF103_standard_peripheral
CFLAGS+=-I$(libdir)/Firmware/RISCV/drivers
CFLAGS+=-I$(libdir)/Firmware
CFLAGS+=-I$(libdir)
#CFLAGS += -MD -MP -MT $(builddir)/$(*F).o -MF $(builddir)/dep/$(@F).mk
CFLAGS+=-DGD32VF103C_START
LDFLAGS := -march=rv32imac -mabi=ilp32 -mcmodel=medany -nostdlib -T$(libdir)/gd32vf103cbt6.ld

frmname = $(progdir)/$(progname)
objs = $(addprefix $(builddir)/,$(addsuffix .o,$(files)))

all: $(frmname).bin $(frmname).hex $(frmname).lss size

$(frmname).bin: $(frmname).elf
	$(OBJCOPY) -O binary $^ $@
$(frmname).hex: $(frmname).elf
	$(OBJCOPY) -Oihex $(frmname).elf $(frmname).hex
$(frmname).lss: $(frmname).elf
	$(OBJDUMP) -D -S $(frmname).elf > $(frmname).lss

$(frmname).elf: $(objs) $(LSCRIPT)
	mkdir -p $(progdir)
	@ echo "..linking"
	$(LD) $(LDFLAGS) $(objs) -o $@ 

$(builddir)/%.o: $(srcdir)/%.c
	mkdir -p $(builddir)
	$(CC) -c $(CFLAGS) $< -o $@
$(builddir)/%.o: $(srcdir)/%.S
	mkdir -p $(builddir)
	$(CC) -c $(ASMFLAGS) $< -o $@
	
clean:
	rm -rf $(progdir)
	rm -rf $(builddir)
size: $(frmname).elf
	$(SIZE) $(frmname).elf
prog: $(frmname).bin
	stm32flash /dev/ttyUSB0 -w $(frmname).bin
dfu: $(frmname).bin
	dfu-util -a 0 -d 28e9:0189 -s 0x08000000 -D $(frmname).bin

-include $(shell mkdir -p $(builddir)/dep) $(wildcard $(builddir)/dep/*)

.PHONY: all clean
