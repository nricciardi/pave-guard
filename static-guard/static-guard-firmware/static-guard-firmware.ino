



void setup() {
  Serial.begin(9600);
}

void loop() {

  int read = digitalRead(PIN);

  Serial.println(read);

  delay(300);
}