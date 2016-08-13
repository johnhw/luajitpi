
ARMGNU ?= arm-none-eabi

COPS = -Wall -Os -nostartfiles -ffreestanding  -march=armv6zk -mtune=arm1176jzf-s -I ../LuaJIT-2.0.4/src -DLUA_32BITS -I ../tcc-working

LIB = -L /home/arm/gcc-arm-none-eabi/arm-none-eabi/lib -L/home/arm/gcc-arm-none-eabi/lib/gcc/arm-none-eabi/4.9.4 -L../LuaJIT-2.0.4/src -L../tcc-working

gcc : luajit.hex luajit.bin

all : gcc

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.bc
	rm -f *.clang.opt.s

vectors.o : vectors.s
	$(ARMGNU)-as vectors.s -o vectors.o

serial.o : serial.c
	$(ARMGNU)-gcc $(COPS) -c serial.c -o serial.o

timer.o : timer.c
	$(ARMGNU)-gcc $(COPS) -c timer.c -o timer.o
    

raspberry.o : raspberry.c
	$(ARMGNU)-gcc $(COPS) -c raspberry.c -o raspberry.o
    
uart02.o : uart02.c
	$(ARMGNU)-gcc $(COPS) -c uart02.c -o uart02.o

ljuart.o : ljuart.c
	$(ARMGNU)-gcc $(COPS) -c ljuart.c -o ljuart.o


    
    
luajit.elf : memmap vectors.o ljuart.o syscalls.o serial.o
	$(ARMGNU)-ld vectors.o ljuart.o syscalls.o serial.o -T memmap -o luajit.elf $(LIB) -lluajit -ltcc -lc -lgcc -lm

luajit.bin : luajit.elf
	$(ARMGNU)-objcopy luajit.elf -O binary luajit.bin

luajit.hex : luajit.elf
	$(ARMGNU)-objcopy luajit.elf -O ihex luajit.hex

syscalls.o : syscalls.c
	$(ARMGNU)-gcc $(COPS) -c $(COPS) syscalls.c -o syscalls.o






