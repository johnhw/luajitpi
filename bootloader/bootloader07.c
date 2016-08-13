
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------

// 2  outer corner
// 4
// 6
// 8  TX out
// 10 RX in


#define RPIBPLUS

/* The base address of the GPIO peripheral (ARM Physical Address) */
#ifdef RPI2
    #define GPIO_BASE       0x3F200000UL
#else
    #define GPIO_BASE       0x20200000UL
#endif

#if defined( RPIBPLUS ) || defined( RPI2 )
    #define LED_GPFSEL      GPIO_GPFSEL4
    #define LED_GPFBIT      21
    #define LED_GPSET       GPIO_GPSET1
    #define LED_GPCLR       GPIO_GPCLR1
    #define LED_GPIO_BIT    15
#else
    #define LED_GPFSEL      GPIO_GPFSEL1
    #define LED_GPFBIT      18
    #define LED_GPSET       GPIO_GPSET0
    #define LED_GPCLR       GPIO_GPCLR0
    #define LED_GPIO_BIT    16
#endif

#define GPIO_GPFSEL0    0
#define GPIO_GPFSEL1    1
#define GPIO_GPFSEL2    2
#define GPIO_GPFSEL3    3
#define GPIO_GPFSEL4    4
#define GPIO_GPFSEL5    5

#define GPIO_GPSET0     7
#define GPIO_GPSET1     8

#define GPIO_GPCLR0     10
#define GPIO_GPCLR1     11

#define GPIO_GPLEV0     13
#define GPIO_GPLEV1     14

#define GPIO_GPEDS0     16
#define GPIO_GPEDS1     17

#define GPIO_GPREN0     19
#define GPIO_GPREN1     20

#define GPIO_GPFEN0     22
#define GPIO_GPFEN1     23

#define GPIO_GPHEN0     25
#define GPIO_GPHEN1     26

#define GPIO_GPLEN0     28
#define GPIO_GPLEN1     29

#define GPIO_GPAREN0    31
#define GPIO_GPAREN1    32

#define GPIO_GPAFEN0    34
#define GPIO_GPAFEN1    35

#define GPIO_GPPUD      37
#define GPIO_GPPUDCLK0  38
#define GPIO_GPPUDCLK1  39

extern void PUT32 ( unsigned int, unsigned int );
extern void PUT16 ( unsigned int, unsigned int );
extern void PUT8 ( unsigned int, unsigned int );
extern unsigned int GET32 ( unsigned int );
extern unsigned int GETPC ( void );
extern void BRANCHTO ( unsigned int );
extern void dummy ( unsigned int );

extern void uart_init ( void );
extern unsigned int uart_lcr ( void );
extern void uart_flush ( void );
extern void uart_send ( unsigned int );
extern unsigned int uart_recv ( void );
extern unsigned int uart_check ( void );
extern void hexstring ( unsigned int );
extern void hexstrings ( unsigned int );
extern void timer_init ( void );
extern unsigned int timer_tick ( void );

extern void timer_init ( void );
extern unsigned int timer_tick ( void );

//------------------------------------------------------------------------
int notmain ( void )
{
    unsigned int state;
    unsigned int byte_count;
    unsigned int address;
    unsigned int record_type;
    unsigned int segment;
    unsigned int data;
    unsigned int sum;
    unsigned int ra;
    unsigned int led_state;
    unsigned int line_count;
    volatile unsigned int *gpio;

    uart_init();
    hexstring(0x12345678);
    hexstring(GETPC());

    uart_send('I');
    uart_send('H');
    uart_send('E');
    uart_send('X');
    uart_send(0x0D);
    uart_send(0x0A);

    state=0;
    segment=0;
    sum=0;
    data=0;
    record_type=0;
    address=0;
    byte_count=0;
    led_state = 0;
    line_count = 0;
    
    gpio = (unsigned int*)GPIO_BASE;
    /* Write 1 to the GPIO16 init nibble in the Function Select 1 GPIO
                   peripheral register to enable GPIO16 as an output */
    gpio[LED_GPFSEL] |= (1 << LED_GPFBIT);
    
    while(1)
    {
        ra=uart_recv();
        if(ra==':')
        {   
            state=1;
            line_count+=1;
            if(line_count==32)
            {
                led_state = !led_state;
                line_count = 0;
                uart_send('.');
                if(led_state)
                {
                   gpio[LED_GPSET] = (1 << LED_GPIO_BIT);
                }
                else
                {
                   gpio[LED_GPCLR] = (1 << LED_GPIO_BIT);   
                }
              
            }
            
            
            continue;
            
        }
        if(ra==0x0D)
        {
            state=0;
            continue;
        }
        if(ra==0x0A)
        {
            state=0;
            continue;
        }
        if((ra=='g')||(ra=='G'))
        {
            uart_send(0x0D);
            uart_send('-');
            uart_send('-');
            uart_send(0x0D);
            uart_send(0x0A);
            uart_send(0x0A);
            BRANCHTO(0x8000);
            state=0;
            break;
        }
        switch(state)
        {
            case 0:
            {
                break;
            }
            case 1:
            case 2:
            {
                byte_count<<=4;
                if(ra>0x39) ra-=7;
                byte_count|=(ra&0xF);
                byte_count&=0xFF;
                state++;
                break;
            }
            case 3:
            case 4:
            case 5:
            case 6:
            {
                address<<=4;
                if(ra>0x39) ra-=7;
                address|=(ra&0xF);
                address&=0xFFFF;
                address|=segment;
                state++;
                break;
            }
            case 7:
            {
                record_type<<=4;
                if(ra>0x39) ra-=7;
                record_type|=(ra&0xF);
                record_type&=0xFF;
                state++;
                break;
            }
            case 8:
            {
                record_type<<=4;
                if(ra>0x39) ra-=7;
                record_type|=(ra&0xF);
                record_type&=0xFF;
                switch(record_type)
                {
                    case 0x00:
                    {
                        state=14;
                        break;
                    }
                    case 0x01:
                    {
			uart_send(0xD);
			uart_send(0xA);

                        hexstring(sum);
                        state=0;
                        break;
                    }
                    case 0x02:
                    {
                        state=9;
                        break;
                    }
                    default:
                    {
                        state=0;
                        break;
                    }
                }
                break;
            }
            case 9:
            case 10:
            case 11:
            case 12:
            {
                segment<<=4;
                if(ra>0x39) ra-=7;
                segment|=(ra&0xF);
                segment&=0xFFFF;
                state++;
                break;
            }
            case 13:
            {
                segment<<=4;
                state=0;
                break;
            }
            case 14:
            case 15:
            case 16:
            case 17:
            case 18:
            case 19:
            case 20:
            case 21:
            {
                data<<=4;
                if(ra>0x39) ra-=7;
                data|=(ra&0xF);
                if(state==21)
                {
                    ra=(data>>24)|(data<<24);
                    ra|=(data>>8)&0x0000FF00;
                    ra|=(data<<8)&0x00FF0000;
                    data=ra;
                    PUT32(address,data);
                    sum+=address;
                    sum+=data;
                    address+=4;
                    state=14;
                }
                else
                {
                    state++;
                }
                break;
            }
        }
    }
    return(0);
}
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------


//-------------------------------------------------------------------------
//
// Copyright (c) 2014 David Welch dwelch@dwelch.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//-------------------------------------------------------------------------
