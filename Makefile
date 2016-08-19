
ARMGNU ?= arm-none-eabi

COPS = -Wall -Os -nostartfiles -ffreestanding  -march=armv6zk -mtune=arm1176jzf-s -I ../LuaJIT-2.0.4/src -DLUA_32BITS -I ../tcc-working -Wformat=0

LIB = -L /home/arm/gcc-arm-none-eabi/arm-none-eabi/lib -L/home/arm/gcc-arm-none-eabi/lib/gcc/arm-none-eabi/4.9.4 -L../LuaJIT-2.0.4/src -Ltcc

gcc : luajit.hex luajit.bin

all : gcc

clean :
	rm -f *.o
	rm -f rboot/*.o    
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.bc
	rm -f *.clang.opt.s


lua_boot.o : lua_boot.lua
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata,alloc,load,readonly,data,contents lua_boot.lua lua_boot.o
    
create_sym.o : create_sym.lua
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata,alloc,load,readonly,data,contents create_sym.lua create_sym.o 
        
luajit_fmap.o : luajit.fmap
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.symdata,alloc,load,readonly,data,contents luajit.fmap luajit_fmap.o
	
sqlite/sqlite3.o : sqlite/sqlite3.c
	echo "Nothing to do"
    
OBJS = vectors.o serial.o ljuart.o lua_boot.o syscalls.o 
OBJS += linenoise/linenoise.o linenoise/linenoise_lua.o 
OBJS += rboot/elf.o rboot/mbox.o rboot/mmio.o rboot/block.o rboot/mbr.o 
OBJS += rboot/emmc.o rboot/libfs.o rboot/fat.o rboot/vfs.o rboot/timer.o
OBJS += rboot/console.o rboot/output.o rboot/font.o rboot/fb.o 
OBJS += rboot/nofs.o rboot/ext2.o rboot/block_cache.o
OBJS += miniz/miniz.o tweetnacl/tweetnacl.o sqlite/sqlite3.o sqlite_stubs.o
OBJS += ldl.o luajit_fmap.o create_sym.o

FLAGS = -DENABLE_FRAMEBUFFER -DENABLE_SERIAL  -DENABLE_DEFAULT_FONT  -DENABLE_SD -DENABLE_MBR  -DENABLE_FAT
FLAGS += -DENABLE_EXT2 -DENABLE_BLOCK_CACHE -DBUILDING_RPIBOOT -DMINIZ_NO_TIME 
    
luajit.elf : memmap $(OBJS)  
	$(ARMGNU)-ld $(OBJS) -T memmap -o luajit.elf $(LIB)  -lluajit -ltcc -lc -lgcc -lm

luajit.fmap : luajit.elf
	readelf luajit.elf -s | grep FUNC | sed "s/ \+/\t/g" | cut -f3,9 > luajit.fmap

luajit.bin : luajit.elf
	$(ARMGNU)-objcopy luajit.elf -O binary luajit.bin

luajit.hex : luajit.elf
	$(ARMGNU)-objcopy luajit.elf -O ihex luajit.hex


%.o: %.c Makefile
	$(ARMGNU)-gcc $(COPS) $(FLAGS) -c $< -o $@

%.o: %.s Makefile
	$(ARMGNU)-as $(ASOPS) -c $< -o $@




