// GND pin -> GND
// Vdd & Gain -> 5V
// Out -> A0
// AR unconnected

int sensorValue;

void setup() {
  Serial.begin(9600);
}

void loop() {
  sensorValue = analogRead(A0);
  Serial.println(sensorValue);
}
