linenoise_example: linenoise.h linenoise.c linenoise_lua.c

linenoise_example: linenoise.c linenoise_lua.c 
	arm-none-eabi-gcc -Wall -W -Os -g -c linenoise.c linenoise_lua.c -I ~/LuaJIT-2.0.4/src
clean:
	rm -f *.o
