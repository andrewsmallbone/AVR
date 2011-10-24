/* 
 * A simple AD9851 Arduino script - non SPI version
 * Andrew Smallbone <andrew@rocketnumbernine.com>
 * Use freely.
 */

#define FQ_UD 6  // connected to AD9851 device select pin
#define W_CLK 13  // connected to AD9851 clock pin
#define DATA 11   // connected to AD9851 D7 (serial data) pin 

#define pulseHigh(pin) {digitalWrite(pin, HIGH); digitalWrite(pin, LOW); }

// transfer a byte a bit at a time LSB first to DATA
void tfr_byte(byte data)
{
  for (int i=0; i<8; i++, data>>=1) {
    digitalWrite(DATA, data & 0x01);
    pulseHigh(W_CLK);
  }
}

// frequency of signwave (datasheet page 12) will be <sys clock> * <frequency tuning word> / 2^32
void sendFrequency(double frequency) {
  int32_t freq = frequency * 4294967296.0 / 180.0e6;
  for (int b=0; b<4; b++, freq>>=8) {
    tfr_byte(freq & 0xFF);
  }
  tfr_byte(0x001);
  pulseHigh(FQ_UD);
}

void setup() {
  // all pins to outputs
  pinMode(FQ_UD, OUTPUT);
  pinMode(W_CLK, OUTPUT);
  pinMode(DATA, OUTPUT);

  // if your board needs it, connect RESET pin and pulse it to reset AD9851
  // pulseHigh(RESET)

  // set serial load enable (Datasheet page 15 Fig. 17) 
  pulseHigh(W_CLK);
  pulseHigh(FQ_UD);
}

void loop() {
  sendFrequency(1.303e3);
  while(1);
}



