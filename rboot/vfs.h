/* Copyright (C) 2013 by John Cronin <jncronin@tysos.org>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef VFS_H
#define VFS_H

struct vfs_file;

#include "dirent.h"
#include "multiboot.h"

#ifndef EOF
#define EOF 0xff
#endif

#ifdef MB_FILE
#undef MB_FILE
#endif
#define MB_FILE struct vfs_file

#include "fs.h"

struct vfs_entry
{
    char *device_name;
    struct fs *fs;
    struct vfs_entry *next;
};

#define VFS_MODE_R		1
#define VFS_MODE_W		2
#define VFS_MODE_RW		3
#define VFS_MODE_APPEND	4
#define VFS_MODE_CREATE	8

#define VFS_FLAGS_EOF	1
#define VFS_FLAGS_ERROR	2

struct vfs_file
{
    struct fs *fs;
    long pos;
	int mode;
    void *opaque;
    long len;
	int flags;
	int (*fflush_cb)(MB_FILE *f);
};

int mb_fseek(MB_FILE *stream, long offset, int whence);
long mb_ftell(MB_FILE *stream);
long mb_fsize(MB_FILE *stream);
int mb_feof(MB_FILE *stream);
int mb_ferror(MB_FILE *stream);
int mb_fflush(MB_FILE *stream);
void mb_rewind(MB_FILE *stream);

int vfs_register(struct fs *fs);
void vfs_list_devices();
char **vfs_get_device_list();
int vfs_set_default(char *dev_name);
char *vfs_get_default();

size_t mb_fread(void *ptr, size_t size, size_t nmemb, MB_FILE *stream);
size_t mb_fwrite(void *ptr, size_t size, size_t nmemb, MB_FILE *stream);
MB_FILE *mb_fopen(const char *path, const char *mode);
int mb_fclose(MB_FILE *fp);
DIR *mb_opendir(const char *name);
struct mb_dirent *readdir(DIR *dirp);
int mb_closedir(DIR *dirp);

#define mb_stdin ((MB_FILE *)0)
#define mb_stdout ((MB_FILE *)1)
#define mb_stderr ((MB_FILE *)2)

#endif

