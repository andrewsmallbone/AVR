#include "MAX6675.h"

#include <WProgram.h>

MAX6675::MAX6675(uint8_t pin) : 
cs(pin)
{
  pinMode(cs, OUTPUT);
  digitalWrite(cs, HIGH);
  setup();
}

void MAX6675::setup()
{
  //  setup_spi(SPI_MODE_1, SPI_MSB, SPI_NO_INTERRUPT, SPI_MSTR_CLK8);
  SPI.setBitOrder(MSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV8);
  SPI.setDataMode(SPI_MODE1);
  SPI.begin();
}

int16_t MAX6675::read()
{
  digitalWrite(cs, LOW);
  uint8_t highByte = SPI.transfer(0);
  uint8_t lowByte = SPI.transfer(0);
  digitalWrite(cs, HIGH);
  if (lowByte & (1<<2)) {
    return -400;
  } 
  else {
    return (highByte << 5 | lowByte>>3);
  } 
}


