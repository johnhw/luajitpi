ffi.cdef([[

struct atag_header {
	uint32_t size;
	uint32_t tag;
};


struct atag_core {
        uint32_t flags;              /* bit 0 = read-only */
        uint32_t pagesize;           /* systems page size (usually 4k) */
        uint32_t rootdev;            /* root device number */
};

struct atag_mem {
        uint32_t     size;   /* size of the area */
        uint32_t     start;  /* physical start address */
};

struct atag_videotext {
        uint8_t              x;           /* width of display */
        uint8_t              y;           /* height of display */
        uint16_t             video_page;
        uint8_t              video_mode;
        uint8_t              video_cols;
        uint16_t             video_ega_bx;
        uint8_t              video_lines;
        uint8_t              video_isvga;
        uint16_t             video_points;
};

struct atag_ramdisk {
        uint32_t flags;      /* bit 0 = load, bit 1 = prompt */
        uint32_t size;       /* decompressed ramdisk size in _kilo_ bytes */
        uint32_t start;      /* starting block of floppy-based RAM disk image */
};

struct atag_initrd2 {
        uint32_t start;      /* physical start address */
        uint32_t size;       /* size of compressed ramdisk image in bytes */
};

struct atag_serialnr {
        uint32_t low;
        uint32_t high;
};

struct atag_revision {
        uint32_t rev;
};

struct atag_videolfb {
        uint16_t             lfb_width;
        uint16_t             lfb_height;
        uint16_t             lfb_depth;
        uint16_t             lfb_linelength;
        uint32_t             lfb_base;
        uint32_t             lfb_size;
        uint8_t              red_size;
        uint8_t              red_pos;
        uint8_t              green_size;
        uint8_t              green_pos;
        uint8_t              blue_size;
        uint8_t              blue_pos;
        uint8_t              rsvd_size;
        uint8_t              rsvd_pos;
};

struct atag_cmdline {
        char    cmdline[1];     /* this is the minimum size */
};

struct atag
{
	struct atag_header hdr;
	union {
		struct atag_core		core;
		struct atag_mem			mem;
		struct atag_videotext		videotext;
		struct atag_ramdisk		ramdisk;
		struct atag_initrd2		initrd2;
		struct atag_serialnr		serialnr;
		struct atag_revision		revision;
		struct atag_videolfb		videolfb;
		struct atag_cmdline		cmdline;
	} u;
};

void parse_atags(uint32_t atags, void (*callback_f)(struct atag *));
]])

local ATAG_NONE	=	0
local ATAG_CORE =		0x54410001
local ATAG_MEM =		0x54410002
local ATAG_VIDEOTEXT= 	 	0x54410003
local ATAG_RAMDISK=		0x54410004
local ATAG_INITRD2=		0x54420005
local ATAG_SERIAL=		0x54410006
local ATAG_REVISION=		0x54410007
local ATAG_VIDEOLFB=		0x54410008
local ATAG_CMDLINE=		0x54410009

local atags = {}

local function parse_atag_callback(tag)
    -- core functionality
    if tag.hdr.tag==ATAG_CORE and tag.hdr.size==5 then
        atags.core = {flags=tag.u.core.flags, pagesize=tag.u.core.pagesize, rootdev=tag.u.core.rootdev}
    end
    -- the memory
    if tag.hdr.tag==ATAG_MEM then
        atags.mem = {start=tag.u.mem.start, size=tag.u.mem.size}
    end
    -- the command line
    if tag.hdr.tag==ATAG_CMDLINE then
        atags.cmdline = {}
        local cmdline_raw = ffi.string(tag.u.cmdline.cmdline)                
        -- split the command line up into space separated elements
        for i in string.gmatch(cmdline_raw, "%S+") do
            local eq = string.find(i, "=")
            -- parse xxx=yyy type arguments
            if eq~=nil then
                local lhs = string.sub(i, 1, eq-1)
                local rhs = string.sub(i, eq+1)                
                atags.cmdline[lhs] = rhs                
            else
                atags.cmdline[i] = true
            end            
        end
        
        
    end
    -- revision number
    if tag.hdr.tag==ATAG_REVISION then
        atags.revision = tag.u.revision.rev
    end
    -- serial number
    if tag.hdr.tag==ATAG_SERIAL then
        atags.serial = {hi=tag.u.serial.high, lo=tag.u.serial.low}
    end    
end

local ATAG_ADDR = 0x100
ffi.C.parse_atags(ATAG_ADDR, parse_atag_callback)
sys.atags = atags

