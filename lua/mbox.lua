ffi.cdef([[


typedef enum {
    /* Videocore */
    TAG_GET_FIRMWARE_VERSION = 0x1,

    /* Hardware */
    TAG_GET_BOARD_MODEL = 0x10001,
    TAG_GET_BOARD_REVISION,
    TAG_GET_BOARD_MAC_ADDRESS,
    TAG_GET_BOARD_SERIAL,
    TAG_GET_ARM_MEMORY,
    TAG_GET_VC_MEMORY,
    TAG_GET_CLOCKS,

    /* Config */
    TAG_GET_COMMAND_LINE = 0x50001,

    /* Shared resource management */
    TAG_GET_DMA_CHANNELS = 0x60001,

    /* Power */
    TAG_GET_POWER_STATE = 0x20001,
    TAG_GET_TIMING,
    TAG_SET_POWER_STATE = 0x28001,

    /* Clocks */
    TAG_GET_CLOCK_STATE = 0x30001,
    TAG_SET_CLOCK_STATE = 0x38001,
    TAG_GET_CLOCK_RATE = 0x30002,
    TAG_SET_CLOCK_RATE = 0x38002,
    TAG_GET_MAX_CLOCK_RATE = 0x30004,
    TAG_GET_MIN_CLOCK_RATE = 0x30007,
    TAG_GET_TURBO = 0x30009,
    TAG_SET_TURBO = 0x38009,

    /* Voltage */
    TAG_GET_VOLTAGE = 0x30003,
    TAG_SET_VOLTAGE = 0x38003,
    TAG_GET_MAX_VOLTAGE = 0x30005,
    TAG_GET_MIN_VOLTAGE = 0x30008,
    TAG_GET_TEMPERATURE = 0x30006,
    TAG_GET_MAX_TEMPERATURE = 0x3000A,
    TAG_ALLOCATE_MEMORY = 0x3000C,
    TAG_LOCK_MEMORY = 0x3000D,
    TAG_UNLOCK_MEMORY = 0x3000E,
    TAG_RELEASE_MEMORY = 0x3000F,
    TAG_EXECUTE_CODE = 0x30010,
    TAG_GET_DISPMANX_MEM_HANDLE = 0x30014,
    TAG_GET_EDID_BLOCK = 0x30020,

    /* Framebuffer */
    TAG_ALLOCATE_BUFFER = 0x40001,
    TAG_RELEASE_BUFFER = 0x48001,
    TAG_BLANK_SCREEN = 0x40002,
    TAG_GET_PHYSICAL_SIZE = 0x40003,
    TAG_TEST_PHYSICAL_SIZE = 0x44003,
    TAG_SET_PHYSICAL_SIZE = 0x48003,
    TAG_GET_VIRTUAL_SIZE = 0x40004,
    TAG_TEST_VIRTUAL_SIZE = 0x44004,
    TAG_SET_VIRTUAL_SIZE = 0x48004,
    TAG_GET_DEPTH = 0x40005,
    TAG_TEST_DEPTH = 0x44005,
    TAG_SET_DEPTH = 0x48005,
    TAG_GET_PIXEL_ORDER = 0x40006,
    TAG_TEST_PIXEL_ORDER = 0x44006,
    TAG_SET_PIXEL_ORDER = 0x48006,
    TAG_GET_ALPHA_MODE = 0x40007,
    TAG_TEST_ALPHA_MODE = 0x44007,
    TAG_SET_ALPHA_MODE = 0x48007,
    TAG_GET_PITCH = 0x40008,
    TAG_GET_VIRTUAL_OFFSET = 0x40009,
    TAG_TEST_VIRTUAL_OFFSET = 0x44009,
    TAG_SET_VIRTUAL_OFFSET = 0x48009,
    TAG_GET_OVERSCAN = 0x4000A,
    TAG_TEST_OVERSCAN = 0x4400A,
    TAG_SET_OVERSCAN = 0x4800A,
    TAG_GET_PALETTE = 0x4000B,
    TAG_TEST_PALETTE = 0x4400B,
    TAG_SET_PALETTE = 0x4800B,
    TAG_SET_CURSOR_INFO = 0x8011,
    TAG_SET_CURSOR_STATE = 0x8010

    } rpi_mailbox_tag_t;


typedef enum {
    TAG_STATE_REQUEST = 0,
    TAG_STATE_RESPONSE = 1,
    } rpi_tag_state_t;


typedef enum {
    PT_OSIZE = 0,
    PT_OREQUEST_OR_RESPONSE = 1,
    } rpi_tag_buffer_offset_t;

typedef enum {
    T_OIDENT = 0,
    T_OVALUE_SIZE = 1,
    T_ORESPONSE = 2,
    T_OVALUE = 3,
    } rpi_tag_offset_t;

typedef struct {
    int tag;
    int byte_length;
    union {
        int value_32;
        unsigned char buffer_8[256];
        int buffer_32[64];
    } data;
    } rpi_mailbox_property_t;

typedef enum {
    TAG_CLOCK_RESERVED = 0,
    TAG_CLOCK_EMMC,
    TAG_CLOCK_UART,
    TAG_CLOCK_ARM,
    TAG_CLOCK_CORE,
    TAG_CLOCK_V3D,
    TAG_CLOCK_H264,
    TAG_CLOCK_ISP,
    TAG_CLOCK_SDRAM,
    TAG_CLOCK_PIXEL,
    TAG_CLOCK_PWM,
    } rpi_tag_clock_id_t;

extern void rpi_property_init( void );
extern void rpi_property_add_tag( rpi_mailbox_tag_t tag, ... );
extern int rpi_property_process( void );
extern rpi_mailbox_property_t* rpi_property_get( rpi_mailbox_tag_t tag );


/* The available mailbox channels in the BCM2835 Mailbox interface.
   See https://github.com/raspberrypi/firmware/wiki/Mailboxes for
   information */
typedef enum {
    MB0_POWER_MANAGEMENT = 0,
    MB0_FRAMEBUFFER,
    MB0_VIRTUAL_UART,
    MB0_VCHIQ,
    MB0_LEDS,
    MB0_BUTTONS,
    MB0_TOUCHSCREEN,
    MB0_UNUSED,
    MB0_TAGS_ARM_TO_VC,
    MB0_TAGS_VC_TO_ARM,
} mbox_channel_t;

/* These defines come from the Broadcom Videocode driver source code, see:
   brcm_usrlib/dag/vmcsx/vcinclude/bcm2708_chip/arm_control.h */
enum mailbox_status_reg_bits {
    ARM_MS_FULL  = 0x80000000,
    ARM_MS_EMPTY = 0x40000000,
    ARM_MS_LEVEL = 0x400000FF,
};

/* Define a structure which defines the register access to a mailbox.
   Not all mailboxes support the full register set! */
typedef struct {
    volatile unsigned int Read;
    volatile unsigned int reserved1[((0x90 - 0x80) / 4) - 1];
    volatile unsigned int Poll;
    volatile unsigned int Sender;
    volatile unsigned int Status;
    volatile unsigned int Configuration;
    volatile unsigned int Write;
    } mailbox_t;

extern void rpi_mbox_write( mbox_channel_t channel, int value );
extern int rpi_mbox_read( mbox_channel_t channel );


]])


tag_set = {{"TAG_GET_BOARD_MODEL", "data32"}, 
            {"TAG_GET_BOARD_REVISION", "data32"},
            {"TAG_GET_FIRMWARE_VERSION", "data32"},
            {"TAG_GET_BOARD_MAC_ADDRESS", "data_buffer_8", 6},
            {"TAG_GET_BOARD_SERIAL", "data_buffer_32", 1},
            }
            
            
local add = ffi.C.rpi_property_add_tag
local init = ffi.C.rpi_property_init
local process = ffi.C.rpi_property_process
local get = ffi.C.rpi_property_get

init()
add(ffi.C.TAG_GET_BOARD_MODEL )
add(ffi.C.TAG_GET_BOARD_REVISION )
add(ffi.C.TAG_GET_FIRMWARE_VERSION )
add(ffi.C.TAG_GET_BOARD_MAC_ADDRESS )
add(ffi.C.TAG_GET_BOARD_SERIAL )
process()

mp = get(ffi.C.TAG_GET_BOARD_MODEL)
atags.model = mp.data.value_32
mp = get(ffi.C.TAG_GET_BOARD_REVISION)
atags.revision = mp.data.value_32
mp = get(ffi.C.TAG_GET_FIRMWARE_VERSION)
atags.firmware = mp.data.value_32
mp = get(ffi.C.TAG_GET_BOARD_MAC_ADDRESS)
atags.mac = ""
for i=1,6 do
    atags.mac = atags.mac..string.format("%02X",mp.data.buffer_8[i])
end
mp = get(ffi.C.TAG_GET_BOARD_SERIAL)
atags.serial = string.format("%08X", mp.data.buffer_32[1]) .. string.format("%08X", mp.data.buffer_32[0])

atags.board = rpi_model_table[atags.revision]