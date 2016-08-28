
ARMGNU ?= arm-none-eabi

COPS = -Wall -Os -nostartfiles -ffreestanding  -march=armv6zk -mtune=arm1176jzf-s -I ../LuaJIT-2.0.4/src -DLUA_32BITS -I tcc -Wformat=0

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
	rm bootfiles.zip
	rm fmap.c

lua_boot.o : lua_boot.lua
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata,alloc,load,readonly,data,contents lua_boot.lua lua_boot.o
    

sqlite/sqlite3.o : sqlite/sqlite3.c
	echo "Nothing to do"
    
OBJS = vectors.o ljuart.o lua_boot.o syscalls.o tcc_wrap.o  ldl.o
OBJS += linenoise/linenoise.o mmu.o
OBJS += rboot/elf.o rboot/mbox.o rboot/mmio.o rboot/block.o rboot/mbr.o 
OBJS += rboot/emmc.o rboot/libfs.o rboot/fat.o rboot/vfs.o rboot/timer.o
OBJS += rboot/console.o rboot/output.o rboot/font.o rboot/fb.o rboot/uart.o
OBJS += rboot/nofs.o rboot/ext2.o rboot/block_cache.o rboot/atag.o
OBJS += miniz/miniz.o tweetnacl/tweetnacl.o 
#OBJS += sqlite_stubs.o sqlite/sqlite3.o sqlite/lsqlite3.o
OBJS += dasm/csrc/dynasm/dasm_arm.o
OBJS += valvers/rpi-mailbox.o valvers/rpi-mailbox-interface.o
OBJS += lpeg-1.0.0/lptree.o lpeg-1.0.0/lpvm.o lpeg-1.0.0/lpprint.o lpeg-1.0.0/lpcode.o lpeg-1.0.0/lpcap.o

FLAGS = -DENABLE_FRAMEBUFFER -DENABLE_SERIAL  -DENABLE_DEFAULT_FONT  -DENABLE_SD -DENABLE_MBR  -DENABLE_FAT
FLAGS += -DENABLE_EXT2 -DENABLE_BLOCK_CACHE -DBUILDING_RPIBOOT -DMINIZ_NO_TIME  -DDASM_CHECKS

bootfiles.zip : lua/*
	zip bootfiles.zip -r lua/
    
bootfiles_zip.o : bootfiles.zip
	$(ARMGNU)-objcopy -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata,alloc,load,readonly,data,contents bootfiles.zip bootfiles_zip.o

luajit.elf : memmap $(OBJS)  fmap_dummy.o bootfiles_zip.o
	$(ARMGNU)-ld $(OBJS) fmap_dummy.o bootfiles_zip.o -T memmap -o luajit.elf $(LIB)  -lluajit -ltcc -lc -lgcc -lm

fmap.c : luajit.elf dl_header._h dl_footer._h
	readelf luajit.elf --wide -s | grep FUNC | awk '{split($$0,l," "); printf("{0x%s,\"%s\"},\n", l[2], l[8]);}' > fmap.pre_h
	cat dl_header._h fmap.pre_h dl_footer._h > fmap.c

fmap.o : fmap.c
	$(ARMGNU)-gcc $(COPS) $(FLAGS) fmap.c -c 
    
luajit_complete.elf : memmap $(OBJS)  bootfiles_zip.o fmap.o
	$(ARMGNU)-ld $(OBJS) fmap.o bootfiles_zip.o -T memmap -o luajit_complete.elf $(LIB)  -lluajit -ltcc -lc -lgcc -lm    

luajit.bin : luajit_complete.elf
	$(ARMGNU)-objcopy luajit_complete.elf -O binary luajit.bin


%.o: %.c Makefile
	$(ARMGNU)-gcc $(COPS) $(FLAGS) -c $< -o $@

%.o: %.s Makefile
	$(ARMGNU)-as $(ASOPS) -c $< -o $@




