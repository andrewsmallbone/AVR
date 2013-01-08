/**
 * A simple incremental Rotary Encoder decoder example
 * andrew@rocketnumbernine.com
 * http://www.rocketnumbernine.com/2010/03/06/decoding-a-rotary-encoder/
 * use freely
*/
#include <util/delay.h>

volatile uint8_t pinValues[2] = {0,0};
volatile int position = 0

void setup()
{
  Serial.begin(19200);
  pinMode(2, INPUT); // 2 Encoder pins as inputs
  pinMode(3, INPUT);
  // enable interrupts on those two pins:
  PCICR |= (1 << PCIE2); 
  PCMSK2 |= (1 << PCINT18) | (1 << PCINT19);
  sei();
}

ISR(PCINT2_vect)
{
  _delay_ms(1);
  int pin0 = digitalRead(2);
  int pin1 = digitalRead(3);
  if (pin0 != pinValues[0]) {
    rotary_encoder_change(0, pin0);
  } else if (pin1 != pinValues[1]) {
    rotary_encoder_change(1, pin1);
  }
} 

void rotary_encoder_change(uint8_t changedPin, uint8_t value)
{
  pinValues[changedPin] = value;
  position += ((pinValues[0] == pinValues[1]) ^ changedPin) ? 1 : -1;
}

void loop()
{
  Serial.println(position);
  delay(100);
}





