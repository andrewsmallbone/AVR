#ifndef MAX6675_H
#define MAX6675_H

#include <SPI.h>

/*
 * A Simple MAX6675 library.
  Example usage:
  MAX6675 thermocouple(8); // A MAX6675 chip select pin is connected to arduino pin 8 (plus the SPI clock and MISO pins)
  
  short temp = thermocouple.read(); // read the temperature of the device - returned as 4*the temp in degrees centigrade
  Serial.print(temp/4); Serial.print("."); Serial.println(temp%4 *25);
  Use Freely.
*/
class MAX6675
{
private:
  uint8_t cs;

public:
  // initialize MAX6675 with chip select pin attached to the specified arduino pin
  MAX6675(uint8_t pin);
  
  // if SPI is used for another device after the constructor has been called setup() can be used to reconfigure
  void setup();
  
  // return the temperature in centigrade * 4.
  int16_t read();
};

#endif
