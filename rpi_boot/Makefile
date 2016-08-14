ARM-CC ?= arm-none-eabi-gcc
ARM-LD ?= arm-none-eabi-ld

all: kernel.elf

CFLAGS := -nostdlib -nostartfiles -ffreestanding -g -I../rpi-boot -std=c99

OBJS = loader.o test_kernel.o syscalls_rpi.o

.PHONY: clean

kernel.elf: $(OBJS) linker.ld
	$(ARM-CC) -nostdlib $(OBJS) -Wl,-T,linker.ld -Wl,-z,max-page-size=0x1000 -o $@ -lgcc

clean:
	$(RM) -f $(OBJS) kernel.elf

%.o: %.c Makefile
	$(ARM-CC) $(CFLAGS) -c $< -o $@

%.o: %.s Makefile
	$(ARM-CC) $(ASFLAGS) -c $< -o $@

