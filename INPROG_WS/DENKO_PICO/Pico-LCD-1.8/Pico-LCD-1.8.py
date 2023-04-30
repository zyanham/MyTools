
from machine import Pin,SPI,PWM
import framebuf
import time

BL = 13
DC = 8
RST = 12
MOSI = 11
SCK = 10
CS = 9



class LCD_1inch8(framebuf.FrameBuffer):
    def __init__(self):
        self.width = 160
        self.height = 128
        
        self.cs = Pin(CS,Pin.OUT)
        self.rst = Pin(RST,Pin.OUT)
        
        self.cs(1)
        self.spi = SPI(1)
        self.spi = SPI(1,1000_000)
        self.spi = SPI(1,10000_000,polarity=0, phase=0,sck=Pin(SCK),mosi=Pin(MOSI),miso=None)
        self.dc = Pin(DC,Pin.OUT)
        self.dc(1)
        self.buffer = bytearray(self.height * self.width * 2)
        super().__init__(self.buffer, self.width, self.height, framebuf.RGB565)
        self.init_display()
        

        self.WHITE =   0xFFFF
        self.BLACK =  0x0000
        self.GREEN =  0x001F
        self.BLUE  =  0xF800
        self.RED   =  0x07E0
        self.ORANGE=  0xC3C2

        
    def write_cmd(self, cmd):
        self.cs(1)
        self.dc(0)
        self.cs(0)
        self.spi.write(bytearray([cmd]))
        self.cs(1)

    def write_data(self, buf):
        self.cs(1)
        self.dc(1)
        self.cs(0)
        self.spi.write(bytearray([buf]))
        self.cs(1)

    def init_display(self):
        """Initialize dispaly"""  
        self.rst(1)
        self.rst(0)
        self.rst(1)
        
        self.write_cmd(0x36);
        self.write_data(0x70);
        
        self.write_cmd(0x3A);
        self.write_data(0x05);

         #ST7735R Frame Rate
        self.write_cmd(0xB1);
        self.write_data(0x01);
        self.write_data(0x2C);
        self.write_data(0x2D);

        self.write_cmd(0xB2);
        self.write_data(0x01);
        self.write_data(0x2C);
        self.write_data(0x2D);

        self.write_cmd(0xB3);
        self.write_data(0x01);
        self.write_data(0x2C);
        self.write_data(0x2D);
        self.write_data(0x01);
        self.write_data(0x2C);
        self.write_data(0x2D);

        self.write_cmd(0xB4); #Column inversion
        self.write_data(0x07);

        #ST7735R Power Sequence
        self.write_cmd(0xC0);
        self.write_data(0xA2);
        self.write_data(0x02);
        self.write_data(0x84);
        self.write_cmd(0xC1);
        self.write_data(0xC5);

        self.write_cmd(0xC2);
        self.write_data(0x0A);
        self.write_data(0x00);

        self.write_cmd(0xC3);
        self.write_data(0x8A);
        self.write_data(0x2A);
        self.write_cmd(0xC4);
        self.write_data(0x8A);
        self.write_data(0xEE);

        self.write_cmd(0xC5); #VCOM
        self.write_data(0x0E);

        #ST7735R Gamma Sequence
        self.write_cmd(0xe0);
        self.write_data(0x0f);
        self.write_data(0x1a);
        self.write_data(0x0f);
        self.write_data(0x18);
        self.write_data(0x2f);
        self.write_data(0x28);
        self.write_data(0x20);
        self.write_data(0x22);
        self.write_data(0x1f);
        self.write_data(0x1b);
        self.write_data(0x23);
        self.write_data(0x37);
        self.write_data(0x00);
        self.write_data(0x07);
        self.write_data(0x02);
        self.write_data(0x10);

        self.write_cmd(0xe1);
        self.write_data(0x0f);
        self.write_data(0x1b);
        self.write_data(0x0f);
        self.write_data(0x17);
        self.write_data(0x33);
        self.write_data(0x2c);
        self.write_data(0x29);
        self.write_data(0x2e);
        self.write_data(0x30);
        self.write_data(0x30);
        self.write_data(0x39);
        self.write_data(0x3f);
        self.write_data(0x00);
        self.write_data(0x07);
        self.write_data(0x03);
        self.write_data(0x10);

        self.write_cmd(0xF0); #Enable test command
        self.write_data(0x01);

        self.write_cmd(0xF6); #Disable ram power save mode
        self.write_data(0x00);

            #sleep out
        self.write_cmd(0x11);
        #DEV_Delay_ms(120);

        #Turn on the LCD display
        self.write_cmd(0x29);

    def show(self):
        self.write_cmd(0x2A)
        self.write_data(0x00)
        self.write_data(0x01)
        self.write_data(0x00)
        self.write_data(0xA0)
        
        
        
        self.write_cmd(0x2B)
        self.write_data(0x00)
        self.write_data(0x02)
        self.write_data(0x00)
        self.write_data(0x81)
        
        self.write_cmd(0x2C)
        
        self.cs(1)
        self.dc(1)
        self.cs(0)
        self.spi.write(self.buffer)
        self.cs(1)

    def write_8(self, pos_x,pos_y):
        LCD.fill_rect(pos_x+2,pos_y+0,6,1,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+1,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+1,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+2,2,5,LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+2,2,5,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+7,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+7,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+8,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+6,pos_y+8,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+9,4,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+10,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+6,pos_y+10,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+11,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+11,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+12,2,6,LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+12,2,6,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+18,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+18,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+19,6,1,LCD.GREEN)

    def write_1(self, pos_x,pos_y):
        LCD.pixel(pos_x, pos_y+3, LCD.GREEN)
        LCD.pixel(pos_x+1, pos_y+2, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+1,1,19,LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y,1,20,LCD.GREEN)
        LCD.fill_rect(pos_x,pos_y+19,6,1,LCD.GREEN)
        
    def write_0(self, pos_x,pos_y):
        LCD.fill_rect(pos_x+3,pos_y,4,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+1,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+6,pos_y+1,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+2,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+2,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+3,2,14,LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+3,2,14,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+17,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+17,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+18,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+6,pos_y+18,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+19,4,1,LCD.GREEN)

    def write_colon(self, pos_x,pos_y):
        LCD.fill_rect(pos_x,pos_y,2,2,LCD.GREEN)
        LCD.fill_rect(pos_x,pos_y+9,2,2,LCD.GREEN)
        
    def write_futsu(self, pos_x,pos_y):
        LCD.pixel(pos_x,pos_y,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+1,1,2,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+2,1,2,LCD.GREEN)
        LCD.pixel(pos_x+8,pos_y,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+1,1,2,LCD.GREEN)
        LCD.fill_rect(pos_x+6,pos_y+2,1,2,LCD.GREEN)
        LCD.fill_rect(pos_x,pos_y+4,11,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+5,2,6,LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+5,2,6,LCD.GREEN)
        LCD.fill_rect(pos_x,pos_y+11,11,1,LCD.GREEN)
        LCD.fill_rect(pos_x,pos_y+8,1,2,LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+10,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+8,1,2,LCD.GREEN)
        LCD.fill_rect(pos_x+9,pos_y+6,1,4,LCD.GREEN)
        LCD.fill_rect(pos_x,pos_y+13,1,10,LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+14,1,9,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+14,6,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+18,6,1,LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+22,6,1,LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+13,2,11,LCD.GREEN)
        LCD.fill_rect(pos_x+16,pos_y+2,6,1,LCD.GREEN)
        LCD.fill_rect(pos_x+12,pos_y+4,1,4,LCD.GREEN)
        LCD.fill_rect(pos_x+13,pos_y+6,1,2,LCD.GREEN)
        LCD.fill_rect(pos_x+20,pos_y+3,1,3,LCD.GREEN)
        LCD.fill_rect(pos_x+21,pos_y+3,1,2,LCD.GREEN)
        LCD.fill_rect(pos_x+11,pos_y+10,3,1,LCD.GREEN)
        LCD.fill_rect(pos_x+11,pos_y+23,2,1,LCD.GREEN)
        LCD.fill_rect(pos_x+12,pos_y+11,2,11,LCD.GREEN)
        LCD.fill_rect(pos_x+13,pos_y+22,10,1,LCD.GREEN)
        LCD.fill_rect(pos_x+14,pos_y+23,8,1,LCD.GREEN)
        LCD.fill_rect(pos_x+18,pos_y+5,1,16,LCD.GREEN)
        LCD.fill_rect(pos_x+19,pos_y+6,1,15,LCD.GREEN)
        LCD.fill_rect(pos_x+17,pos_y+8,4,1,LCD.GREEN)
        LCD.fill_rect(pos_x+17,pos_y+11,4,1,LCD.GREEN)
        LCD.fill_rect(pos_x+17,pos_y+14,4,1,LCD.GREEN)
        LCD.fill_rect(pos_x+15,pos_y+8,2,13,LCD.GREEN)
        LCD.fill_rect(pos_x+21,pos_y+8,2,13,LCD.GREEN)

    def write_tokkyu (self, pos_x, pos_y) :
        LCD.pixel(pos_x+10,2,LCD.ORANGE)
        LCD.fill_rect(pos_x+6,3,5,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+0,6,6,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+0,1,1,6,LCD.ORANGE)
        LCD.fill_rect(pos_x+2,0,2,23,LCD.ORANGE)
        LCD.fill_rect(pos_x+7,0,2,9,LCD.ORANGE)
        LCD.fill_rect(pos_x+8,9,2,14,LCD.ORANGE)
        LCD.fill_rect(pos_x+5,8,7,1,LCD.ORANGE)
        LCD.pixel(pos_x+11,7,LCD.ORANGE)
        LCD.fill_rect(pos_x+0,14,1,2,LCD.ORANGE)
        LCD.fill_rect(pos_x+1,13,1,2,LCD.ORANGE)
        LCD.pixel(pos_x+4,12,LCD.ORANGE)
        LCD.pixel(pos_x+5,11,LCD.ORANGE)
        LCD.fill_rect(pos_x+5,14,7,1,LCD.ORANGE)
        LCD.pixel(pos_x+11,13,LCD.ORANGE)
        LCD.fill_rect(pos_x+5,17,1,2,LCD.ORANGE)
        LCD.fill_rect(pos_x+6,18,1,2,LCD.ORANGE)
        LCD.fill_rect(pos_x+6,21,2,1,LCD.ORANGE)
        
        LCD.fill_rect(pos_x+11,17,1,4,LCD.ORANGE)
        LCD.fill_rect(pos_x+12,16,1,4,LCD.ORANGE)
        LCD.pixel(pos_x+14,4,LCD.ORANGE)
        LCD.fill_rect(pos_x+15,0,1,4,LCD.ORANGE)
        LCD.fill_rect(pos_x+16,0,1,3,LCD.ORANGE)
        LCD.fill_rect(pos_x+19,1,2,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+17,2,5,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+18,3,3,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+18,4,2,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+17,5,2,1,LCD.ORANGE)
    
        LCD.fill_rect(pos_x+14,6,8,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+20,6,1,7,LCD.ORANGE)
        LCD.fill_rect(pos_x+21,6,1,8,LCD.ORANGE)
        LCD.fill_rect(pos_x+14,9,8,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+14,12,8,1,LCD.ORANGE)
    
        LCD.fill_rect(pos_x+17,14,1,4,LCD.ORANGE)
        LCD.fill_rect(pos_x+18,16,1,3,LCD.ORANGE)
        LCD.pixel(pos_x+19,14,LCD.ORANGE)
        LCD.fill_rect(pos_x+20,15,1,3,LCD.ORANGE)
        LCD.fill_rect(pos_x+21,16,1,2,LCD.ORANGE)
        
        LCD.fill_rect(pos_x+14,17,2,5,LCD.ORANGE)
        LCD.fill_rect(pos_x+16,21,6,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+15,22,6,1,LCD.ORANGE)
        LCD.fill_rect(pos_x+20,19,1,2,LCD.ORANGE)


    def write_shimoda(self, pos_x, pos_y) :
        LCD.fill_rect(pos_x+0,pos_y+11,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+9,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+10,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+6,2,17, LCD.GREEN)
        LCD.fill_rect(pos_x+4,pos_y+3,2,4, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+0,2,4, LCD.GREEN)
        LCD.pixel(pos_x+7,pos_y+1, LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+3,8,1, LCD.GREEN)
        LCD.pixel(pos_x+12,pos_y+2, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+21,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+6,pos_y+20,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+19,2,2, LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+16,2,3, LCD.GREEN)
        LCD.fill_rect(pos_x+9,pos_y+4,2,13, LCD.GREEN)
        LCD.fill_rect(pos_x+13,pos_y+1,1,14, LCD.GREEN)
        LCD.fill_rect(pos_x+14,pos_y+2,1,13, LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+13,6,1, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+8,22,1, LCD.GREEN)
        LCD.fill_rect(pos_x+16,pos_y+3,11,1, LCD.GREEN)
        LCD.pixel(pos_x+25,pos_y+1, LCD.GREEN)
        LCD.fill_rect(pos_x+24,pos_y+2,3,1, LCD.GREEN)
        LCD.pixel(pos_x+16,pos_y+6, LCD.GREEN)
        LCD.fill_rect(pos_x+16,pos_y+7,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+24,pos_y+7,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+17,pos_y+9,2,5, LCD.GREEN)
        LCD.fill_rect(pos_x+24,pos_y+9,2,5, LCD.GREEN)
        LCD.fill_rect(pos_x+19,pos_y+13,5,1, LCD.GREEN)
        LCD.fill_rect(pos_x+16,pos_y+14,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+17,pos_y+15,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+18,pos_y+16,1,6, LCD.GREEN)
        LCD.fill_rect(pos_x+19,pos_y+17,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+15,pos_y+21,14,1, LCD.GREEN)
        LCD.fill_rect(pos_x+22,pos_y+15,2,4, LCD.GREEN)
        LCD.fill_rect(pos_x+21,pos_y+18,1,3, LCD.GREEN)
        LCD.pixel(pos_x+22,pos_y+19, LCD.GREEN)
        LCD.pixel(pos_x+29,pos_y+16, LCD.GREEN)
        LCD.fill_rect(pos_x+24,pos_y+20,5,1, LCD.GREEN)
        LCD.pixel(pos_x+25,pos_y+19, LCD.GREEN)
        LCD.fill_rect(pos_x+32,pos_y+0,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+31,pos_y+1,3,2, LCD.GREEN)
        LCD.fill_rect(pos_x+36,pos_y+1,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+34,pos_y+2,5,1, LCD.GREEN)
        LCD.fill_rect(pos_x+30,pos_y+3,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+35,pos_y+5,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+29,pos_y+4,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+35,pos_y+4,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+28,pos_y+5,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+34,pos_y+5,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+39,pos_y+5,2,9, LCD.GREEN)
        LCD.fill_rect(pos_x+28,pos_y+6,14,1, LCD.GREEN)
        LCD.fill_rect(pos_x+28,pos_y+9,11,1, LCD.GREEN)
        LCD.fill_rect(pos_x+28,pos_y+12,11,1, LCD.GREEN)
        LCD.fill_rect(pos_x+28,pos_y+17,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+29,pos_y+15,1,5, LCD.GREEN)
        LCD.fill_rect(pos_x+33,pos_y+14,2,3, LCD.GREEN)
        LCD.fill_rect(pos_x+31,pos_y+15,2,7, LCD.GREEN)
        LCD.fill_rect(pos_x+34,pos_y+17,2,2, LCD.GREEN)
        LCD.pixel(pos_x+35,pos_y+19, LCD.GREEN)
        LCD.fill_rect(pos_x+36,pos_y+16,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+37,pos_y+17,3,3, LCD.GREEN)
        LCD.fill_rect(pos_x+32,pos_y+22,7,1, LCD.GREEN)
        LCD.fill_rect(pos_x+33,pos_y+23,5,1, LCD.GREEN)
        LCD.pixel(pos_x+36,pos_y+21, LCD.GREEN)
        LCD.fill_rect(pos_x+37,pos_y+20,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+39,pos_y+19,2,3, LCD.GREEN)
        LCD.fill_rect(pos_x+41,pos_y+2,23,1, LCD.GREEN)
        LCD.pixel(pos_x+52,pos_y+0, LCD.GREEN)
        LCD.pixel(pos_x+62,pos_y+0, LCD.GREEN)
        LCD.fill_rect(pos_x+51,pos_y+1,4,1, LCD.GREEN)
        LCD.fill_rect(pos_x+61,pos_y+1,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+46,pos_y+3,2,20, LCD.GREEN)
        LCD.fill_rect(pos_x+54,pos_y+3,2,20, LCD.GREEN)
        LCD.fill_rect(pos_x+58,pos_y+3,2,18, LCD.GREEN)
        LCD.fill_rect(pos_x+62,pos_y+3,2,20, LCD.GREEN)
        LCD.fill_rect(pos_x+48,pos_y+7,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+49,pos_y+8,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+50,pos_y+9,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+51,pos_y+10,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+56,pos_y+11,6,1, LCD.GREEN)
        LCD.fill_rect(pos_x+56,pos_y+20,6,1, LCD.GREEN)

    def write_odawara(self, pos_x, pos_y) :
        LCD.fill_rect(pos_x+0,pos_y+16,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+15,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+13,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+10,1,4, LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+7,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+4,pos_y+8,1,4, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+8,1,2, LCD.GREEN)
        LCD.pixel(pos_x+6,pos_y+8, LCD.GREEN)
        LCD.pixel(pos_x+9,pos_y+1, LCD.GREEN)
        LCD.pixel(pos_x+12,pos_y+2, LCD.GREEN)
        LCD.fill_rect(pos_x+10,pos_y+1,2,21, LCD.GREEN)
        LCD.fill_rect(pos_x+6,pos_y+21,4,1, LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+22,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+14,pos_y+7,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+15,pos_y+8,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+16,pos_y+9,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+17,pos_y+10,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+18,pos_y+11,2,2, LCD.GREEN)
        LCD.fill_rect(pos_x+19,pos_y+13,2,3, LCD.GREEN)
        LCD.fill_rect(pos_x+24,pos_y+3,2,18, LCD.GREEN)
        LCD.fill_rect(pos_x+38,pos_y+3,2,18, LCD.GREEN)
        LCD.fill_rect(pos_x+31,pos_y+3,2,16, LCD.GREEN)
        LCD.fill_rect(pos_x+37,pos_y+2,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+26,pos_y+3,12,1, LCD.GREEN)
        LCD.fill_rect(pos_x+26,pos_y+11,12,1, LCD.GREEN)
        LCD.fill_rect(pos_x+26,pos_y+19,12,1, LCD.GREEN)
        LCD.fill_rect(pos_x+45,pos_y+0,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+59,pos_y+0,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+46,pos_y+1,2,16, LCD.GREEN)
        LCD.fill_rect(pos_x+46,pos_y+17,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+45,pos_y+18,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+44,pos_y+20,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+48,pos_y+1,14,1, LCD.GREEN)
        LCD.pixel(pos_x+55,pos_y+2, LCD.GREEN)
        LCD.fill_rect(pos_x+54,pos_y+3,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+49,pos_y+4,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+53,pos_y+4,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+59,pos_y+4,2,9, LCD.GREEN)
        LCD.fill_rect(pos_x+50,pos_y+5,12,1, LCD.GREEN)
        LCD.fill_rect(pos_x+50,pos_y+6,2,7, LCD.GREEN)
        LCD.fill_rect(pos_x+52,pos_y+9,7,1, LCD.GREEN)
        LCD.fill_rect(pos_x+52,pos_y+12,7,1, LCD.GREEN)
        LCD.pixel(pos_x+52,pos_y+15, LCD.GREEN)
        LCD.fill_rect(pos_x+51,pos_y+14,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+50,pos_y+16,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+49,pos_y+17,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+48,pos_y+18,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+54,pos_y+13,2,9, LCD.GREEN)
        LCD.fill_rect(pos_x+51,pos_y+21,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+53,pos_y+22,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+57,pos_y+14,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+58,pos_y+15,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+60,pos_y+16,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+61,pos_y+17,2,2, LCD.GREEN)
        LCD.fill_rect(pos_x+62,pos_y+18,2,2, LCD.GREEN)

    def write_kozu(self, pos_x, pos_y):
        LCD.fill_rect(pos_x+0,pos_y+3,2,19, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+4,12,1, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+19,12,1, LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+6,10,1, LCD.GREEN)
        LCD.pixel(pos_x+11,pos_y+5, LCD.GREEN)
        LCD.fill_rect(pos_x+7,pos_y+7,2,10, LCD.GREEN)
        LCD.fill_rect(pos_x+4,pos_y+11,8,1, LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+17,10,1, LCD.GREEN)
        LCD.fill_rect(pos_x+10,pos_y+12,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+11,pos_y+13,2,2, LCD.GREEN)
        LCD.fill_rect(pos_x+11,pos_y+16,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+13,pos_y+2,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+14,pos_y+3,2,19, LCD.GREEN)
        LCD.fill_rect(pos_x+21,pos_y+3,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+28,pos_y+1,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+29,pos_y+2,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+29,pos_y+3,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+22,pos_y+4,16,1, LCD.GREEN)
        LCD.fill_rect(pos_x+35,pos_y+3,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+22,pos_y+5,2,12, LCD.GREEN)
        LCD.fill_rect(pos_x+22,pos_y+17,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+21,pos_y+18,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+20,pos_y+20,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+26,pos_y+5,2,2, LCD.GREEN)
        LCD.fill_rect(pos_x+27,pos_y+6,2,2, LCD.GREEN)
        LCD.pixel(pos_x+24,pos_y+11, LCD.GREEN)
        LCD.fill_rect(pos_x+26,pos_y+8,2,14, LCD.GREEN)
        LCD.fill_rect(pos_x+25,pos_y+9,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+32,pos_y+5,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+33,pos_y+6,4,1, LCD.GREEN)
        LCD.fill_rect(pos_x+28,pos_y+11,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+29,pos_y+9,8,1, LCD.GREEN)
        LCD.fill_rect(pos_x+34,pos_y+7,2,15, LCD.GREEN)
        LCD.fill_rect(pos_x+29,pos_y+12,1,2, LCD.GREEN)
        LCD.fill_rect(pos_x+30,pos_y+13,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+31,pos_y+14,1,2, LCD.GREEN)
        LCD.pixel(pos_x+36,pos_y+18, LCD.GREEN)
        LCD.fill_rect(pos_x+31,pos_y+21,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+33,pos_y+22,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+42,pos_y+2,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+43,pos_y+3,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+44,pos_y+4,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+42,pos_y+7,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+43,pos_y+8,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+44,pos_y+9,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+42,pos_y+20,2,3, LCD.GREEN)
        LCD.pixel(pos_x+43,pos_y+19, LCD.GREEN)
        LCD.fill_rect(pos_x+44,pos_y+16,1,4, LCD.GREEN)
        LCD.fill_rect(pos_x+45,pos_y+11,1,7, LCD.GREEN)
        LCD.fill_rect(pos_x+50,pos_y+0,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+49,pos_y+1,4,1, LCD.GREEN)
        LCD.fill_rect(pos_x+51,pos_y+2,2,21, LCD.GREEN)
        LCD.fill_rect(pos_x+47,pos_y+4,10,1, LCD.GREEN)
        LCD.fill_rect(pos_x+47,pos_y+9,10,1, LCD.GREEN)
        LCD.fill_rect(pos_x+46,pos_y+7,14,1, LCD.GREEN)
        LCD.fill_rect(pos_x+55,pos_y+5,2,4, LCD.GREEN)
        LCD.fill_rect(pos_x+58,pos_y+7,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+48,pos_y+12,9,1, LCD.GREEN)
        LCD.fill_rect(pos_x+54,pos_y+11,2,1, LCD.GREEN)
        LCD.fill_rect(pos_x+46,pos_y+17,13,1, LCD.GREEN)
        LCD.fill_rect(pos_x+55,pos_y+16,3,1, LCD.GREEN)
        LCD.pixel(pos_x+56,pos_y+15, LCD.GREEN)

    def write_8ryo(self, pos_x, pos_y):
        LCD.fill_rect(pos_x+3,pos_y+0,5,1, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+1,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+1,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+4,5,1, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+5,1,4, LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+5,1,4, LCD.GREEN)
        LCD.fill_rect(pos_x+3,pos_y+9,5,1, LCD.GREEN)
        
        LCD.fill_rect(pos_x+0,pos_y+12,11,1, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+13,1,7, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+17,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+19,7,1, LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+17,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+15,1,7, LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+15,11,1, LCD.GREEN)
        LCD.fill_rect(pos_x+10,pos_y+15,1,7, LCD.GREEN)
        LCD.pixel(pos_x+9,pos_y+21, LCD.GREEN)

    def write_15ryo(self, pos_x, pos_y):
        LCD.pixel(pos_x+0,pos_y+1, LCD.GREEN)
        LCD.fill_rect(pos_x+1,pos_y+0,1,10, LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+9,3,1, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+0,5,1, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+0,1,5, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+4,5,1, LCD.GREEN)
        LCD.fill_rect(pos_x+9,pos_y+4,1,6, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+9,5,1, LCD.GREEN)
        
        LCD.fill_rect(pos_x+0,pos_y+12,11,1, LCD.GREEN)
        LCD.fill_rect(pos_x+5,pos_y+13,1,7, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+17,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+2,pos_y+19,7,1, LCD.GREEN)
        LCD.fill_rect(pos_x+8,pos_y+17,1,3, LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+15,1,7, LCD.GREEN)
        LCD.fill_rect(pos_x+0,pos_y+15,11,1, LCD.GREEN)
        LCD.fill_rect(pos_x+10,pos_y+15,1,7, LCD.GREEN)
        LCD.pixel(pos_x+9,pos_y+21, LCD.GREEN)


if __name__=='__main__':
    pwm = PWM(Pin(BL))
    pwm.freq(1000)
    pwm.duty_u16(32768)#max 65535

    LCD = LCD_1inch8()
    #color BRG
    LCD.fill(LCD.BLACK)
 
    LCD.show()
  
    ######################
    ## Lane 1
    ######################
    LCD.write_tokkyu(0,0)
    LCD.write_1(26,1)
    LCD.write_1(35,1)
    LCD.write_colon(43,6)
    LCD.write_0(47,1)
    LCD.write_0(59,1)
    LCD.write_shimoda(74,0)
    LCD.write_8ryo(145,0)

    ######################
    ## Lane 2
    ######################
    LCD.write_futsu(0,24)
    LCD.write_1(26,26)
    LCD.write_1(35,26)
    LCD.write_colon(43,31)
    LCD.write_0(47,26)
    LCD.write_8(59,26)
    LCD.write_odawara(75,24)
    LCD.write_15ryo(145,25)

    ######################
    ## Lane 3
    ######################
    LCD.write_futsu(0,49)
    LCD.write_1(26,50)
    LCD.write_1(35,50)
    LCD.write_colon(43,55)
    LCD.write_1(49,50)
    LCD.write_8(59,50)
    LCD.write_kozu(78,49)
    LCD.write_15ryo(145,50)


#    LCD.pixel(,,LCD.GREEN)
#    LCD.fill_rect(,,,,LCD.GREEN)



#    LCD.rect(0,120,160,10,0X8430)

#   LCD.pixel(x, y, color)
#   LCD.pixel(0, 0 , LCD.GREEN)
#   LCD.pixel(1, 0 , LCD.GREEN)
            
            
    LCD.show()
    time.sleep(1)
    LCD.fill(0xFFFF)




