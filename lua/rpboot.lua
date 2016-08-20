ffi.cdef([[

struct block_device;
struct mb_dirent;
struct MB_FILE;
struct mb_dir_info;
struct fs;

typedef uint32_t usecs_t;

struct block_device {
	char *driver_name;
	char *device_name;
	uint8_t *device_id;
	size_t dev_id_len;

	int supports_multiple_block_read;
	int supports_multiple_block_write;

	int (*read)(struct block_device *dev, uint8_t *buf, size_t buf_size, uint32_t block_num);
	int (*write)(struct block_device *dev, uint8_t *buf, size_t buf_size, uint32_t block_num);
	size_t block_size;
	size_t num_blocks;

	struct fs *fs;
};

size_t block_read(struct block_device *dev, uint8_t *buf, size_t buf_size, uint32_t starting_block);
size_t block_write(struct block_device *dev, uint8_t *buf, size_t buf_size, uint32_t starting_block);


typedef struct mb_dirent {
	struct mb_dirent *next;
        char *name;
	uint32_t byte_size;
	uint8_t is_dir;
	void *opaque;
	struct fs *fs;
} mb_dirent;

typedef struct MB_FILE
{
    struct fs *fs;
    long pos;
	int mode;
    void *opaque;
    long len;
	int flags;
	int (*fflush_cb)(struct MB_FILE *f);
} MB_FILE;

typedef struct mb_dir_info { 
	struct mb_dirent *first;
	struct mb_dirent *next;
} DIR;



uint8_t *fb_get_framebuffer();
int fb_init();
int fb_get_bpp();
int fb_get_byte_size();
int fb_get_width();
int fb_get_height();
int fb_get_pitch();


struct fs {
	struct block_device *parent;
	const char *fs_name;
	uint32_t flags;
	size_t block_size;

	MB_FILE *(*fopen)(struct fs *, struct mb_dirent *, const char *mode);
	size_t (*fread)(struct fs *, void *ptr, size_t byte_size, MB_FILE *stream);
	size_t (*fwrite)(struct fs *, void *ptr, size_t byte_size, MB_FILE *stream);
	int (*fclose)(struct fs *, MB_FILE *fp);
	long (*fsize)(MB_FILE *fp);
    int (*fseek)(MB_FILE *stream, long offset, int whence);
	long (*ftell)(MB_FILE *fp);
	int (*fflush)(MB_FILE *fp);

	struct mb_dirent *(*read_directory)(struct fs *, char **name);
};

int register_fs(struct block_device *dev, int part_id);
int fs_interpret_mode(const char *mode);
size_t fs_fread(uint32_t (*get_next_bdev_block_num)(uint32_t f_block_idx, MB_FILE *s, void *opaque, int add_blocks),
	struct fs *fs, void *ptr, size_t byte_size,
	MB_FILE *stream, void *opaque);
size_t fs_fwrite(uint32_t (*get_next_bdev_block_num)(uint32_t f_block_idx, MB_FILE *s, void *opaque, int add_blocks),
	struct fs *fs, void *ptr, size_t byte_size,
	MB_FILE *stream, void *opaque);

uint32_t mbox_read(uint8_t channel);
void mbox_write(uint8_t channel, uint32_t data);

void mmio_write(uint32_t reg, uint32_t data);
uint32_t mmio_read(uint32_t reg);


struct timer_wait
{
	uint32_t trigger_value;
	int rollover;
};

int usleep(usecs_t usec);
struct timer_wait register_timer(usecs_t usec);
int compare_timer(struct timer_wait tw);

void uart_init();
int uart_putc(int byte);
void uart_puts(const char *str);
int uart_getc();
int uart_getc_timeout(usecs_t timeout);


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

void libfs_init(void);

size_t mb_fread(void *ptr, size_t size, size_t nmemb, MB_FILE *stream);
size_t mb_fwrite(void *ptr, size_t size, size_t nmemb, MB_FILE *stream);
MB_FILE *mb_fopen(const char *path, const char *mode);
int mb_fclose(MB_FILE *fp);
DIR *mb_opendir(const char *name);
struct mb_dirent *mb_readdir(DIR *dirp);
int mb_closedir(DIR *dirp);

]])
