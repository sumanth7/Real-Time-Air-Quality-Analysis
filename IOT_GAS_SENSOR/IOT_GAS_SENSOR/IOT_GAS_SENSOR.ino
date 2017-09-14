/* Connection pins:

Arduino       MQ-135
  A0            A0
 +5V            VCC
 GND            GND
 
*/

#include "MQ135.h"

int analogPin = 0;
int inPin = 7;

MQ135 gasSensor = MQ135(analogPin);


//#define RZEROC 310 // 76.63

int i = 0;

double result;
double rzero;

void setup() {
  Serial.begin(9600);
  pinMode(inPin, INPUT);
}

void loop() {
 
 if (i==0) {
   rzero = gasSensor.getRZero(); // float
 }
 if (i>0) {  
   result = gasSensor.getRZero();
   rzero = (rzero + result)/2;
  }
  float ppm = gasSensor.getPPM();
  
  Serial.print(rzero);
  Serial.print(", ");
  Serial.print(result);
  Serial.print(", ");
  Serial.print(ppm);
  //Serial.println(" ppm");
  Serial.print("\n");
  i++;
  delay(200);
}
