#! /usr/bin/env bash

# Target and build configuration.
TARGET=arm-none-eabi
PREFIX=/home/arm/gcc-arm-none-eabi

# Sources to build from.
BINUTILS=binutils-2.27
GCC=gcc-4.9.4
NEWLIB=newlib-2.4.0
GDB=gdb-7.9

MIRROR=www.mirrorservice.org/sites/ftp.gnu.org/gnu
NEWLIB_MIRROR=ftp.mirrorservice.org/sites/sourceware.org/pub

# Grab the souce files...but only if they don't already exist.
if [ ! -e ${BINUTILS}.tar.bz2 ]; then
    echo "Grabbing ${BINUTILS}.tar.bz2"
    curl ftp://${MIRROR}/binutils/${BINUTILS}.tar.bz2 -o ${BINUTILS}.tar.bz2
fi
if [ ! -e ${GCC}.tar.bz2 ]; then
    echo "Grabbing ${GCC}.tar.bz2"
    curl ftp://${MIRROR}/gcc/${GCC}/${GCC}.tar.bz2 -o ${GCC}.tar.bz2
fi
if [ ! -e ${NEWLIB}.tar.gz ]; then
    echo "Grabbing ${NEWLIB}.tar.gz"
    curl ftp://${NEWLIB_MIRROR}/newlib/${NEWLIB}.tar.gz -o ${NEWLIB}.tar.gz
fi
if [ ! -e ${GDB}.tar.bz2 ]; then
    echo "Grabbing ${GDB}.tar.bz2"
    curl ftp://${MIRROR}/gdb/${GDB}.tar.gz -o ${GDB}.tar.gz
fi

# Extract the sources.
echo -n "extracting binutils... "
tar -jxf ${BINUTILS}.tar.bz2
echo "done"
echo -n "extracting gcc... "
tar -jxf ${GCC}.tar.bz2
echo "done"
echo -n "extracting newlib... "
tar -zxf ${NEWLIB}.tar.gz
echo "done"
echo -n "extracting gdb... "
tar -xf ${GDB}.tar.gz
echo "done"

# Build a set of compatible Binutils for this architecture.  Need this before
# we can build GCC.
echo Building binutils...
mkdir binutils-build
cd binutils-build
../${BINUTILS}/configure --target=${TARGET} --prefix=${PREFIX} --disable-nls \
    --enable-interwork --enable-multilib --disable-werror
make all install 2>&1 | tee ../make.log
cd ..

# Add the new Binutils to the path for use in building GCC and Newlib.
export PATH=$PATH:${PREFIX}:${PREFIX}/bin

echo Building gcc...
# Build and configure GCC with the Newlib C runtime. Note that the 'with-gmp',
# 'with-mpfr' and 'with-libconv-prefix' are needed only for Mac OS X using the
# MacPorts system.
cd ${GCC}
# The following symbolic links are only needed if building Newlib as well.
ln -s ../${NEWLIB}/newlib .
ln -s ../${NEWLIB}/libgloss .
mkdir ../gcc-build
cd ../gcc-build
echo "CONFIGURING GCC"
../${GCC}/configure --target=${TARGET} --prefix=${PREFIX} \
    --with-newlib --with-gnu-as --with-gnu-ld --disable-nls --disable-libssp \
    --disable-newlib-supplied-syscalls \
    --disable-gomp --disable-libstcxx-pch --enable-threads --disable-shared \
    --disable-libmudflap --enable-interwork --enable-languages=c,c++ 
make all install 2>&1 | tee -a ../make.log
# Use the following instead if only building and installing GCC (i.e. without Newlib).
#make all-gcc install-gcc 2>&1 | tee -a ../make.log
cd ..

echo Building gdb...
# Build GDB.
mkdir gdb-build
cd gdb-build
../${GDB}/configure --target=${TARGET} --prefix=${PREFIX} \
    --disable-interwork --enable-multilib --disable-werror
make all install 2>&1 | tee -a ../make.log
cd ..

# We are done, let the user know were the new compiler and tools are.
echo ""
echo "Cross GCC for ${TARGET} installed to ${PREFIX}"
echo ""
