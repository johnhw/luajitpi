
ARMGNU ?= arm-none-eabi

COPS = -Wall -Os -nostartfiles -ffreestanding  -march=armv6zk -mtune=arm1176jzf-s -I ../LuaJIT-2.0.4/src -DLUA_32BITS -I ../tcc-working -Wformat=0

LIB = -L /home/arm/gcc-arm-none-eabi/arm-none-eabi/lib -L/home/arm/gcc-arm-none-eabi/lib/gcc/arm-none-eabi/4.9.4 -L../LuaJIT-2.0.4/src -Ltcc

gcc : luajit.bin

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
	touch luajit.fmap


lua_boot.o : lua_boot.lua
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata,alloc,load,readonly,data,contents lua_boot.lua lua_boot.o
    
create_sym.o : create_sym.lua
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata,alloc,load,readonly,data,contents create_sym.lua create_sym.o 
        
	
sqlite/sqlite3.o : sqlite/sqlite3.c
	echo "Nothing to do"
    
OBJS = vectors.o serial.o ljuart.o lua_boot.o syscalls.o tcc_wrap.o
OBJS += linenoise/linenoise.o 
OBJS += rboot/elf.o rboot/mbox.o rboot/mmio.o rboot/block.o rboot/mbr.o 
OBJS += rboot/emmc.o rboot/libfs.o rboot/fat.o rboot/vfs.o rboot/timer.o
OBJS += rboot/console.o rboot/output.o rboot/font.o rboot/fb.o 
OBJS += rboot/nofs.o rboot/ext2.o rboot/block_cache.o
OBJS += miniz/miniz.o tweetnacl/tweetnacl.o 
OBJS += sqlite_stubs.o
OBJS += ldl.o create_sym.o
OBJS += lpeg-1.0.0/lptree.o lpeg-1.0.0/lpvm.o lpeg-1.0.0/lpprint.o lpeg-1.0.0/lpcode.o lpeg-1.0.0/lpcap.o

FLAGS = -DENABLE_FRAMEBUFFER -DENABLE_SERIAL  -DENABLE_DEFAULT_FONT  -DENABLE_SD -DENABLE_MBR  -DENABLE_FAT
FLAGS += -DENABLE_EXT2 -DENABLE_BLOCK_CACHE -DBUILDING_RPIBOOT -DMINIZ_NO_TIME 
    
luajit.elf : memmap $(OBJS)  luajit_fmap.o
	$(ARMGNU)-ld $(OBJS) luajit_fmap.o -T memmap -o luajit.elf $(LIB)  -lluajit -ltcc -lc -lgcc -lm

luajit.fmap : luajit.elf
	readelf luajit.elf -s | grep FUNC | sed "s/ \+/\t/g" | cut -f3,9 > luajit.fmap

luajit_fmap.o : luajit.fmap
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.symdata,alloc,load,readonly,data,contents luajit.fmap luajit_fmap.o

    
luajit_complete.elf : memmap $(OBJS) luajit_fmap.o
	$(ARMGNU)-ld $(OBJS) luajit_fmap.o -T memmap -o luajit_complete.elf $(LIB)  -lluajit -ltcc -lc -lgcc -lm    

luajit.bin : luajit_complete.elf
	$(ARMGNU)-objcopy luajit_complete.elf -O binary luajit.bin


%.o: %.c Makefile
	$(ARMGNU)-gcc $(COPS) $(FLAGS) -c $< -o $@

%.o: %.s Makefile
	$(ARMGNU)-as $(ASOPS) -c $< -o $@




