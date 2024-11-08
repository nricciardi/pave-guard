
int PIN = 8;


void setup() {
  pinMode(PIN, INPUT_PULLUP);

  Serial.begin(9600);
}

void loop() {

  int read = digitalRead(PIN);

  Serial.println(read);

  delay(300);
}