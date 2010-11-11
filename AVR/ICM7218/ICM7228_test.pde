/* 
 * Copyright (c) 2010 Andrew Smallbone <andrew@rocketnumbernine.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#define MODE_PIN 10
#define WRITE_PIN 11
#define ID0_PIN 2
#define ID_PIN(i) ID0_PIN+i
#define SETDP(i) i &= 0x7F

void setup() {
  pinMode(WRITE_PIN, OUTPUT);
  digitalWrite(WRITE_PIN, HIGH);
  pinMode(MODE_PIN, OUTPUT);

  for (int i=0; i<8; i++) {
    pinMode(ID_PIN(i), OUTPUT);
    digitalWrite(ID_PIN(i), HIGH);
  }
}

void writePulse() {
  digitalWrite(WRITE_PIN, LOW);
  // 250ns delay not explicitly required
  digitalWrite(WRITE_PIN, HIGH);
}

void sendBytes(unsigned char data[], int length, boolean mode)
{
  digitalWrite(MODE_PIN, mode);
  for (int i=0; i<length; i++) {
    for (int c=0; c<8; c++) {
      digitalWrite(ID_PIN(c), data[i] & 1<<c);
    }
    writePulse();
  }
}

void sendCommand(unsigned char control, unsigned char digit[], int length)
{
  sendBytes(&control, 1, 1);
  sendBytes(digit, length, 0);
}

void loop()
{
  // send a sequence of digits - "5 4 3 2 1 0"
  // note that the high bit is set 0x80 to turn off the decimal point
  unsigned char digits[] = { 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87 };
  sendCommand(1<<4 | 1<<6 | 1<<7, digits, 8);
 
  delay(1000);
 
  // repeat the above but one digit at a time (with decimal points)
  for (unsigned char i=0; i<8; i++) {
    // i will fill the 3 low bits of the command byte(ID0, ID1, and ID2)
    // ID4 = turn on device,  ID6 = hex mode
    sendCommand(i | 1<<4 | 1<<6, &i, 1);
    delay(500);  
  }

  delay(1000); 

  // no decode mode - light each segment in turn - repeat on all digits
  unsigned char segment[] = { 1<<6 | 0x80, 1<<5 | 0x80, 1<<2 | 0x80,
       1<<3 | 0x80, 1<<0 | 0x80, 1<<4 | 0x80, 1<<2 | 0x80, 1<<1 | 0x80};
  for (int i=0; i<3; i++) {
    for (unsigned char digit=0; digit<8; digit++) {
      for (int j=0; j<8; j++) { 
        sendCommand(digit | 1<<4 | 1<<5, &segment[j], 1);
        delay(50);
      }
    }
  }

  delay(1000);  

  // count up 
  for (int count=0; count<999999; count++) {
    unsigned char digit[8];
    for (int power=1, i=0; i<8; i++, power*=10) {
      digit[i] = (count/power % 10) | 0x80;
    }
    sendCommand(1<<4 | 1<<6 | 1<<7, digit, 8);
    delay(50);
  }

  
  while(1);
}












