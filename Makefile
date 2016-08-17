
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


lua_boot.o : lua_boot.lua
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata,alloc,load,readonly,data,contents lua_boot.lua lua_boot.o
	
    
OBJS = vectors.o serial.o timer.o ljuart.o lua_boot.o syscalls.o 
OBJS += linenoise/linenoise.o linenoise/linenoise_lua.o 
OBJS += elf.o mbox.o mmio.o block.o mbr.o emmc.o libfs.o fat.o vfs.o
OBJS += console.o output.o font.o fb.o nofs.o ext2.o block_cache.o

FLAGS = -DENABLE_FRAMEBUFFER -DENABLE_SERIAL  -DENABLE_DEFAULT_FONT  -DENABLE_SD -DENABLE_MBR  -DENABLE_FAT
FLAGS += -DENABLE_EXT2 -DENABLE_BLOCK_CACHE
    
luajit.elf : memmap $(OBJS)  
	$(ARMGNU)-ld $(OBJS) -T memmap -o luajit.elf $(LIB) -lluajit -ltcc -lc -lgcc -lm

luajit.bin : luajit.elf
	$(ARMGNU)-objcopy luajit.elf -O binary luajit.bin

luajit.hex : luajit.elf
	$(ARMGNU)-objcopy luajit.elf -O ihex luajit.hex


%.o: %.c Makefile
	$(ARMGNU)-gcc $(COPS) $(FLAGS) -c $< -o $@

%.o: %.s Makefile
	$(ARMGNU)-as $(ASOPS) -c $< -o $@




