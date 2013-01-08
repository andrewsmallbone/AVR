/* 
 * A simple AD9851 Arduino script - SPI version
 * see http://www.rocketnumbernine.com/2011/10/25/programming-the-ad9851-dds-synthesizer
 * Andrew Smallbone <andrew@rocketnumbernine.com>
 * Use freely.
 */

#include <SPI.h>
#define FQ_UD 6  // connected to AD9851 device select pin
#define W_CLK 13  // connected to AD9851 clock pin
#define DATA 11   // connected to AD9851 D7 (serial data) pin 

#define pulseHigh(pin) {digitalWrite(pin, HIGH); digitalWrite(pin, LOW); }

// frequency of signwave (datasheet page 12) will be <sys clock> * <frequency tuning word> / 2^32
void sendFrequency(double frequency) {
  int32_t freq = frequency * 4294967296.0 / 180.0e6;
  // send each byte of the frequency lowest byte first
  for (int b=0; b<4; b++, freq>>=8) {
    SPI.transfer(freq & 0xFF);
  }
  // control byte - all zero except last digit (clock multiplier enable)
  // see datasheet table III. page 16.
  SPI.transfer(0x001);
  pulseHigh(FQ_UD);
}

void setup() {
  // all pins to outputs
  pinMode(FQ_UD, OUTPUT);
  pinMode(W_CLK, OUTPUT);
  pinMode(DATA, OUTPUT);

  SPI.begin();
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST); 
  
  // if your board needs it, connect RESET pin and pulse it to reset AD9851
  // pulseHigh(RESET)

  // set serial load enable (Datasheet page 15 Fig. 17) 
  pulseHigh(W_CLK);
  pulseHigh(FQ_UD);
}

void loop() {
  sendFrequency(1.331e6);
  while(1);
}


