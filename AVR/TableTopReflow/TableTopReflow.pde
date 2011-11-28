/**
* Simple work in progress Toaster Oven reflow controller.
* currently just allows selection of max temp with dial, turns on heating elements until the max is reached.
* Copyright 2011 andrew@rocketnumbernine.com
* See http://www.rocketnumbernine.com/2011/11/28/smt-table-top-reflow-oven-part-3
* Copy and use freely at your own risk.
*/
#include <LiquidCrystal.h>
#include <SPI.h>
#include "MAX6675.h"

#include <util/delay.h>

// MAX6675 thermocouple select on pin 8  also connected to SPI clock (pin 13) and MISO (pin 12)
MAX6675 thermocouple(8);

#define OVEN_LOWER 6
#define OVEN_UPPER 7

#define LED 9

#define ENCODER_RIGHT 2
#define ENCODER_LEFT 3
#define ENCODER_PUSH 4

// LCD pins RS, Enable, D4, D5, D6, D7
LiquidCrystal lcd(A0, A1, A2, A3, A4, A5);


volatile double target_temp=250;
double actual_temp;
unsigned long started_at;

boolean reached = false;
boolean on = false;
double last_temp;
double rate_of_change;
short period = 200;

volatile unsigned long last_changed = 0;
volatile uint8_t pinValues[2] = {0,0};

void knob_turned()
{
  _delay_ms(1);
  int pin0 = digitalRead(ENCODER_LEFT);
  int pin1 = digitalRead(ENCODER_RIGHT);
  if (pin0 != pinValues[0]) {
    rotary_encoder_change(0, pin0);
  } else if (pin1 != pinValues[1]) {
    rotary_encoder_change(1, pin1);
  }
}

void rotary_encoder_change(uint8_t changedPin, uint8_t value)
{
  pinValues[changedPin] = value;
  // only increment for each 'click' of the dial - when both pins have gone back to 0
  if (value == 0 && pinValues[0] == pinValues[1]) {
    unsigned long this_change = millis();
    // if the change is within 50ms of the last then move 10 positions
    short multiplier = (last_changed != 0 && (this_change - last_changed) < 50) ? 10 : 1;
    target_temp += ((changedPin) ? 1 : -1) * multiplier;
    last_changed = this_change;
  }
}

void setup()
{
  Serial.begin(19200);
  lcd.begin(16, 2);
  lcd.clear();
  
  // pins to control oven bars - upper and lower
  pinMode(OVEN_UPPER, OUTPUT);
  pinMode(OVEN_LOWER, OUTPUT);
  
  pinMode(LED, OUTPUT);
  analogWrite(LED, 0);
  
  // rotary encoder - 3 pins with pullup resistors
  pinMode(ENCODER_LEFT, INPUT);
  digitalWrite(ENCODER_LEFT, HIGH);
  pinMode(ENCODER_RIGHT, INPUT);
  digitalWrite(ENCODER_RIGHT, HIGH);
  pinMode(ENCODER_PUSH, INPUT);
  digitalWrite(ENCODER_PUSH, HIGH);
  
  attachInterrupt(0, knob_turned, CHANGE);
  attachInterrupt(1, knob_turned, CHANGE);
}



void update_display()
{
  char buf[17];

  // temperature
  dtostrf(actual_temp, 3, 0, buf);
  strcpy(buf+3, "C ");

  // rate of change, explicit fixed precision: "+9.9"
  buf[5] = rate_of_change > 0 ? '+' : '-';
  //buf[6] = ((int )rate_of_change) + '0';
  //buf[7] = '.';
  //buf[8] = ((int )rate_of_change/10.0) + '0';
  dtostrf(abs(rate_of_change*(1000/period)), 3, 1, buf+6);
  
  strcpy(buf+9, on ? "    on" : "   off");
  
  lcd.setCursor(0,0);
  lcd.print(buf);
  
  strcpy(buf, "     target:");
  if (started_at != 0) {
    dtostrf((millis()-started_at)/1000, 3, 0, buf);
    buf[3] = 's';
  }
    
  dtostrf(target_temp, 3, 0, buf+12);

  buf[16] = 0;
  lcd.setCursor(0,1);
  lcd.print(buf);

  Serial.print(millis()-started_at);Serial.print(",");Serial.print(on?1:0);Serial.print(",");Serial.println(actual_temp);
}

void set_oven(boolean on)
{
  digitalWrite(OVEN_LOWER, on);
  digitalWrite(OVEN_UPPER, on); 
  analogWrite(LED, on ? 70 : 0);
}

void loop()
{
  last_temp = actual_temp;
  actual_temp = thermocouple.read() / 4.0;

  // use a moving average of rate of change - thermocouple is only accurate to a few degrees
  rate_of_change = ((actual_temp-last_temp)*0.1+rate_of_change*0.9);
  
  // if push button toggle on/off
  if (!digitalRead(ENCODER_PUSH)) {
    if (!on) {
      Serial.println("started");
      started_at = millis();
    }
    on ^= 1;
  }
  
  // if off reset reached to false
  if (!on) {
     reached = false;
  }

  // if actual temp < target we've reached target 
  if (actual_temp >= target_temp) {
    reached = true;
  }  



  set_oven(on && !reached);

  update_display();

  delay(period);
}