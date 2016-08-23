/* Support files for GNU libc.  Files in the system namespace go here.
   Files in the C namespace (ie those that do not start with an
   underscore) go in .c.  */

#include <_ansi.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <sys/times.h>
#include <errno.h>
#include <reent.h>
#include "mem.h"
#include "rboot/vfs.h"

int getch(void);
int putch(int c);

unsigned int heap_end=MEM_HEAP_START;
unsigned int prev_heap_end;

/* Forward prototypes.  */
int     _system     _PARAMS ((const char *));
int     _rename     _PARAMS ((const char *, const char *));
int     isatty      _PARAMS ((int));
clock_t _times      _PARAMS ((struct tms *));
int     _gettimeofday   _PARAMS ((struct timeval *, struct timezone *));
void    _raise      _PARAMS ((void));
int     _unlink     _PARAMS ((void));
int     _link       _PARAMS ((void));
int     _stat       _PARAMS ((const char *, struct stat *));
int     _fstat      _PARAMS ((int, struct stat *));
caddr_t _sbrk       _PARAMS ((int));
int     _getpid     _PARAMS ((int));
int     _kill       _PARAMS ((int, int));
void    _exit       _PARAMS ((int));
int     _close      _PARAMS ((int));
int     _open       _PARAMS ((const char *, int, ...));
int     _write      _PARAMS ((int, char *, int));
int     _lseek      _PARAMS ((int, int, int));
int     _read       _PARAMS ((int, char *, int));
void    initialise_monitor_handles _PARAMS ((void));

//static int
//remap_handle (int fh)
//{
    //return 0;
//}

void
initialise_monitor_handles (void)
{
}

//static int
//get_errno (void)
//{
    //return(0);
//}

//static int
//error (int result)
//{
  //errno = get_errno ();
  //return result;
//}


void uart_putc ( unsigned int c );
unsigned int uart_getc ( void );

#define FILE_STDIN 0
#define FILE_STDOUT 1
#define FILE_STDERR 2

#define MB_MAX_FILE_HANDLES 256
static MB_FILE *file_handles[MB_MAX_FILE_HANDLES] = {0};


int
_read (int file,
       char * ptr,
       int len)
{
  int r; 
  if(file==FILE_STDIN)
  {
        for(r=0;r<len;r++) ptr[r] = uart_getc();
        return len;       
  }
  else
  {
    if(file_handles[file])    
        return mb_fread(ptr, 1, len, file_handles[file]);            
    return -1;
  }
}


int
_lseek (int file,
    int ptr,
    int dir)
{    
    if(file<=FILE_STDERR)
        return 0;
    /* Translate whence constants */
    if(dir==SEEK_SET) dir=MB_SEEK_SET;
    if(dir==SEEK_CUR) dir=MB_SEEK_CUR;
    if(dir==SEEK_END) dir=MB_SEEK_END;
       
    if(file_handles[file]!=NULL)    
        return mb_fseek(file_handles[file], ptr, dir);
    return -1;
    
}


int
_write (int    file,
    char * ptr,
    int    len)
{
    int r;  
    if(1)//file==FILE_STDOUT || file==FILE_STDERR)
    {
        for(r=0;r<len;r++) uart_putc(ptr[r]);    
        return len;
    }
    return -1;
}

int
_open (const char * path,
       int          flags,
       ...)
{
                
    MB_FILE *f = mb_fopen(path, "r");
    if(f)
    {   
        int i;
        for(i=FILE_STDERR+1;i<MB_MAX_FILE_HANDLES;i++)        
            if(file_handles[i]==NULL) break;        
        if(i==MB_MAX_FILE_HANDLES) return -1;
        file_handles[i] = f;
        return i;
    }    
    return -1;
    
}


int
_close (int file)
{
    if(file<=FILE_STDERR || file_handles[file]==NULL)
        return -1;
    int result = mb_fclose(file_handles[file]);
    file_handles[file]=NULL;
    return result;
}

void
_exit (int n)
{
    while(1);
}

int
_kill (int n, int m)
{
    return(0);
}

int
_getpid (int n)
{
  return 1;
  n = n;
}


caddr_t
_sbrk (int incr)
{
    prev_heap_end = heap_end;
    heap_end += incr;
    
    // Align up to a 4096 byte address
	if(heap_end & 0xfff)
	{
		heap_end &= ~0xfff;
		heap_end += 0x1000;
	}
    
    return (caddr_t) prev_heap_end;
}




int
_fstat (int file, struct stat * st)
{
  if(file<=FILE_STDERR)
    return 0;
  return 0;
}

int _stat (const char *fname, struct stat *st)
{
  return 0;
}

int
_link (void)
{
  return -1;
}

int
_unlink (void)
{
  return -1;
}

void
_raise (void)
{
  return;
}

int
_gettimeofday (struct timeval * tp, struct timezone * tzp)
{
    if(tp)
    {
        tp->tv_sec = 10;
        tp->tv_usec = 0;
    }
    if (tzp)
    {
        tzp->tz_minuteswest = 0;
        tzp->tz_dsttime = 0;
    }
    return 0;
}

clock_t
_times (struct tms * tp)
{
    clock_t timeval;

    timeval = 10;
    if (tp)
    {
        tp->tms_utime  = timeval;   /* user time */
        tp->tms_stime  = 0; /* system time */
        tp->tms_cutime = 0; /* user time, children */
        tp->tms_cstime = 0; /* system time, children */
    }
    return timeval;
};


int
_isatty (int fd)
{
  return 1;
  fd = fd;
}

int
_system (const char *s)
{
  if (s == NULL)
    return 0;
  errno = ENOSYS;
  return -1;
}

int
_rename (const char * oldpath, const char * newpath)
{
  errno = ENOSYS;
  return -1;
}

void abort()
{
	while(1)
 {
 }
}

// for NaCL
void randombytes(uint8_t * x, uint64_t n)
{
}
