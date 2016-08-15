ARM-CC ?= arm-none-eabi-gcc
ARM-LD ?= arm-none-eabi-ld

all: kernel.elf

CFLAGS := -nostdlib -nostartfiles -ffreestanding -O2 -std=c99 -march=armv6zk -mtune=arm1176jzf-s -I ../../LuaJIT-2.0.4/src -DLUA_32BITS -I ../../tcc-working

LIB = -L /home/arm/gcc-arm-none-eabi/arm-none-eabi/lib -L/home/arm/gcc-arm-none-eabi/lib/gcc/arm-none-eabi/4.9.4 -L../../LuaJIT-2.0.4/src -L../../tcc-working


OBJS = loader.o luajit_kernel.o syscalls_rpi.o 

.PHONY: clean

#luajit.elf : memmap vectors.o ljuart.o syscalls.o serial.o
#	$(ARMGNU)-ld vectors.o ljuart.o syscalls.o serial.o -T memmap -o luajit.elf $(LIB) -lluajit -ltcc -lc -lgcc -lm

kernel.elf: $(OBJS) linker.ld
	$(ARM-CC) $(OBJS) $(CFLAGS) -Wl,-T,linker.ld -Wl,-z,max-page-size=0x1000 -o $@ $(LIB) -lluajit -ltcc -lc -lgcc -lm

clean:
	$(RM) -f $(OBJS) kernel.elf

%.o: %.c Makefile
	$(ARM-CC) $(CFLAGS) -c $< -o $@

%.o: %.s Makefile
	$(ARM-CC) $(ASFLAGS) -c $< -o $@

