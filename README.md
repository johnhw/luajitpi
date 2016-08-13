# luajitpi
LuaJIT + TCC on RPi bare metal

## Compiling
I built the `arm-none-eabi toolchain` from source on Linux using a modified version of the script from https://gist.github.com/cjmeyer/4251208
I used:

* binutils 1.27
* GCC 4.9.4
* newlib 2.4.0
* gdb 7.2

The script I used is included in `build_toolchain/` as `arm-none-eabi.sh`

## LuaJIT
LuaJIT compiles easily if you:

modify

and compile with:

  make HOST_CC="gcc -m32" CROSS="arm-none-eabi-"
  

## TCC
I had to modify TCC slightly to make it compile without standard libraries or dynamic link support; see the modified version in `tcc/`. Note that TCC is distributed under an LGPL license. The modification just add some stubs to `tccrun.c`.

## UART access
I based the UART access on dwelch67's [newlib example](https://github.com/dwelch67/raspberrypi/tree/master/newlib0)

