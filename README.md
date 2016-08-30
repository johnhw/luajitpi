# luajitpi
LuaJIT + TinyCC on RPi bare metal.


**This has only been tested on an RPi B+. The changes to make this run on the RPi2 are probably easy (just the GPIO addresses) but I've not tested this!**

## Compiling
I built the `arm-none-eabi toolchain` from source on Linux (lubuntu on x64) using a modified version of the script from https://gist.github.com/cjmeyer/4251208
I used:

* binutils 2.27
* GCC 4.9.4
* newlib 2.4.0
* gdb 7.9

The script I used is included in `build_toolchain/` as `arm-none-eabi.sh`

The Debian `arm-none-eabi` package may also work, but I haven't tried it yet.

## LuaJIT
[LuaJIT 2.0.4](http://luajit.org/download/LuaJIT-2.0.4.tar.gz) compiles easily if you:

modify the Makefile to uncomment the line

        XCFLAGS += -DLUAJIT_USE_SYSMALLOC

(which forces LuaJIT to use the newlib `malloc()`) 
and change the `BUILDMODE` from `mixed` to `static`
    
        BUILDMODE= static
        
then compile with:
        make HOST_CC="gcc -m32" CROSS="arm-none-eabi-"

To enable dynamic link loading, edit lj_arch.h and adjust the LJ_TARGET_DLOPEN to

	#define LJ_TARGET_DLOPEN 1

add edit lj_clib.c and lib_package.c to include "ldl.h" instead of <dlfcn.h>.

  
Note that luajit itself won't build (because `libdl` is missing) but this isn't important as `libluajit.a` will be built succesfully.

## TinyCC
I had to modify TCC slightly to make it compile without standard libraries or dynamic link support; see the modified version in `tcc/`. Note that TCC is distributed under an LGPL license. The modification just add some stubs to `tccrun.c`, and adjust the Makefile to remove `libdl`

I used [version 0.9.26 of TinyCC](http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.26.tar.bz2).

## UART access
I based the UART access on dwelch67's [newlib example](https://github.com/dwelch67/raspberrypi/tree/master/newlib0), but the current version uses the code from rpi-boot.

The bootloader in `bootloader/` is a slightly modified version of dwelch67's [`bootloader07`](https://github.com/dwelch67/raspberrypi/tree/master/bootloader07) (it prints dots and flashes the LED during loading, as the images are very large and it is nice to see some progress indication!).


