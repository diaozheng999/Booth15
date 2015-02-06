

#define IN_A 3
#define LED 13

int state =0;

void setup(){
    pinMode(IN_A, INPUT_PULLUP);
    pinMode(LED, OUTPUT);
    digitalWrite(LED, LOW);

    Serial.begin(9600);
    Serial.println("Ready");
}

void loop(){
    if(state == 0 && digitalRead(IN_A) == LOW){
        Serial.println("low");
        state = 1;
        digitalWrite(LED, LOW);
    }
    else if(state == 1 && digitalRead(IN_A) == HIGH){
        Serial.println("high");
        state = 0;
        digitalWrite(LED, HIGH);

    }
}


