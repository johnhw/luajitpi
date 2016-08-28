ffi = require('ffi')
-- force ffi to call dlopen()
ffi.load("default")
miniz = ffi.C

-- define the zip file loading code
ffi.cdef([[
typedef unsigned int size_t;
typedef void *(*mz_alloc_func)(void *opaque, size_t items, size_t size);
typedef void (*mz_free_func)(void *opaque, void *address);
typedef void *(*mz_realloc_func)(void *opaque, void *address, size_t items, size_t size);
typedef unsigned char mz_uint8;
typedef signed short mz_int16;
typedef unsigned short mz_uint16;
typedef unsigned int mz_uint32;
typedef unsigned int mz_uint;
typedef long long mz_int64;
typedef unsigned long long mz_uint64;
typedef int mz_bool;
enum
{
  MZ_ZIP_MAX_IO_BUF_SIZE = 64*1024,
  MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE = 260,
  MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE = 256
};

typedef struct
{
  mz_uint32 m_file_index;
  mz_uint32 m_central_dir_ofs;
  mz_uint16 m_version_made_by;
  mz_uint16 m_version_needed;
  mz_uint16 m_bit_flag;
  mz_uint16 m_method;
  mz_uint32 m_crc32;
  mz_uint64 m_comp_size;
  mz_uint64 m_uncomp_size;
  mz_uint16 m_internal_attr;
  mz_uint32 m_external_attr;
  mz_uint64 m_local_header_ofs;
  mz_uint32 m_comment_size;
  char m_filename[MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE];
  char m_comment[MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE];
} mz_zip_archive_file_stat;

typedef size_t (*mz_file_read_func)(void *pOpaque, mz_uint64 file_ofs, void *pBuf, size_t n);
typedef size_t (*mz_file_write_func)(void *pOpaque, mz_uint64 file_ofs, const void *pBuf, size_t n);

struct mz_zip_internal_state_tag;
typedef struct mz_zip_internal_state_tag mz_zip_internal_state;

typedef enum
{
  MZ_ZIP_MODE_INVALID = 0,
  MZ_ZIP_MODE_READING = 1,
  MZ_ZIP_MODE_WRITING = 2,
  MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED = 3
} mz_zip_mode;

typedef struct mz_zip_archive_tag
{
  mz_uint64 m_archive_size;
  mz_uint64 m_central_directory_file_ofs;
  mz_uint m_total_files;
  mz_zip_mode m_zip_mode;

  mz_uint m_file_offset_alignment;

  mz_alloc_func m_pAlloc;
  mz_free_func m_pFree;
  mz_realloc_func m_pRealloc;
  void *m_pAlloc_opaque;

  mz_file_read_func m_pRead;
  mz_file_write_func m_pWrite;
  void *m_pIO_opaque;

  mz_zip_internal_state *m_pState;

} mz_zip_archive;


typedef enum
{
  MZ_ZIP_FLAG_CASE_SENSITIVE                = 0x0100,
  MZ_ZIP_FLAG_IGNORE_PATH                   = 0x0200,
  MZ_ZIP_FLAG_COMPRESSED_DATA               = 0x0400,
  MZ_ZIP_FLAG_DO_NOT_SORT_CENTRAL_DIRECTORY = 0x0800
} mz_zip_flags;
mz_bool mz_zip_reader_init(mz_zip_archive *pZip, mz_uint64 size, mz_uint32 flags);
mz_bool mz_zip_reader_init_mem(mz_zip_archive *pZip, const void *pMem, size_t size, mz_uint32 flags);
mz_uint mz_zip_reader_get_num_files(mz_zip_archive *pZip);
mz_bool mz_zip_reader_file_stat(mz_zip_archive *pZip, mz_uint file_index, mz_zip_archive_file_stat *pStat);
mz_bool mz_zip_reader_is_file_a_directory(mz_zip_archive *pZip, mz_uint file_index);
mz_bool mz_zip_reader_is_file_encrypted(mz_zip_archive *pZip, mz_uint file_index);
mz_uint mz_zip_reader_get_filename(mz_zip_archive *pZip, mz_uint file_index, char *pFilename, mz_uint filename_buf_size);
int mz_zip_reader_locate_file(mz_zip_archive *pZip, const char *pName, const char *pComment, mz_uint flags);
mz_bool mz_zip_reader_extract_to_mem_no_alloc(mz_zip_archive *pZip, mz_uint file_index, void *pBuf, size_t buf_size, mz_uint flags, void *pUser_read_buf, size_t user_read_buf_size);
mz_bool mz_zip_reader_extract_file_to_mem_no_alloc(mz_zip_archive *pZip, const char *pFilename, void *pBuf, size_t buf_size, mz_uint flags, void *pUser_read_buf, size_t user_read_buf_size);
mz_bool mz_zip_reader_extract_to_mem(mz_zip_archive *pZip, mz_uint file_index, void *pBuf, size_t buf_size, mz_uint flags);
mz_bool mz_zip_reader_extract_file_to_mem(mz_zip_archive *pZip, const char *pFilename, void *pBuf, size_t buf_size, mz_uint flags);
void *mz_zip_reader_extract_to_heap(mz_zip_archive *pZip, mz_uint file_index, size_t *pSize, mz_uint flags);
void *mz_zip_reader_extract_file_to_heap(mz_zip_archive *pZip, const char *pFilename, size_t *pSize, mz_uint flags);
mz_bool mz_zip_reader_extract_to_callback(mz_zip_archive *pZip, mz_uint file_index, mz_file_write_func pCallback, void *pOpaque, mz_uint flags);
mz_bool mz_zip_reader_extract_file_to_callback(mz_zip_archive *pZip, const char *pFilename, mz_file_write_func pCallback, void *pOpaque, mz_uint flags);
mz_bool mz_zip_reader_extract_to_file(mz_zip_archive *pZip, mz_uint file_index, const char *pDst_filename, mz_uint flags);
mz_bool mz_zip_reader_extract_file_to_file(mz_zip_archive *pZip, const char *pArchive_filename, const char *pDst_filename, mz_uint flags);
mz_bool mz_zip_reader_end(mz_zip_archive *pZip);
]])

-- open a zip file, returning an object representing it
function openzip(memptr, size)
    zip = ffi.new("mz_zip_archive")
    miniz.mz_zip_reader_init_mem(zip, memptr, size, 0)
    return {zip=zip, expand=expandzip, list=listzip, close=closezip}
end

-- expand a file from a zip archive, returing a new Lua string
function expandzip(zip, fname)
    expanded_size = ffi.new("size_t[1]")
    data = miniz.mz_zip_reader_extract_file_to_heap(zip.zip, fname, expanded_size, 0)
    return ffi.string(data, tonumber(expanded_size[0]))
end

-- list each file in a zip archive, as a table 
function listzip(zip)
    local n_files = miniz.mz_zip_reader_get_num_files(zip.zip)
    local files = {}
    local stat = ffi.new("mz_zip_archive_file_stat")
    for i = 1,n_files do
        miniz.mz_zip_reader_file_stat(zip.zip, i-1, stat)
        table.insert(files, {filename=ffi.string(stat.m_filename), compressed_len=tonumber(stat.m_comp_size), uncompressed_len=tonumber(stat.m_uncomp_size)})
    end
    return files
end

-- close a zip file
function closezip(zip)
    miniz.mz_zip_reader_end(zip.zip)
end

-- point to the zip file compiled in
bootzip = openzip(ffi.cast("void*", bootzip_ptr), bootzip_len)
 
function console_error(err) print("ERROR:", err) end

-- run a file from the zip archive
function run_bootzip(fname)
    local src = bootzip:expand(fname)
    f, err = loadstring(src)
    if f==nil then 
        console_error(err)
        return nil        
    else 
        status, ret = xpcall(f, console_error)
        if status==nil then
            print("Error in "..fname)
            return nil
        else
            return ret
        end
    end
end

-- run each given file from the boot zip file
function boot(files)
    for k,v in ipairs(files) do
        print("\t\tBOOT: executing "..v)
        run_bootzip(v)
    end
end

boot({"lua/test.lua", 
    "lua/zip_require.lua", 
    "lua/sys.lua",
    "lua/linenoise.lua", 
    "lua/repl.lua", 
    "lua/rpboot.lua", 
    "lua/fs.lua", 
    "lua/tweetnacl.lua", 
    "lua/asm.lua", 
    "lua/cc.lua", 
    "lua/atags.lua",
    "lua/rpimodels.lua",
    "lua/mbox.lua", 
    "lua/more_tests.lua"})

if repl~=nil then 
  repl()
else
    -- fallback repl
    while true do
       line = io.read()
       f,err = loadstring(line)
       if f then
           xpcall(f,debug.traceback)
       end
    end
end

