// ir_ranger_01
// threshold analog sensor data
// bjoern@stanford.edu 2/12/08, revised 12/15/08

import net.eriksjodin.arduino.Arduino;
import net.eriksjodin.arduino.events.ArduinoEvent;

trace("start");
var inputPin:Number = 8; //which analog input pin?
var ledPin:Number = 13;

var arduino:Arduino = new Arduino("127.0.0.1", 5331);

const IDLE:Number=0;
const ALARM:Number=1;
var mode:Number=IDLE; //0
var threshold:Number=511;
txtThreshold.text = threshold.toString(); //show threshold on screen
var state:Number =0;

trace("middle");
// we first ask for the Firmware version, when it comes back, we know it's safe to initialize
arduino.addEventListener(ArduinoEvent.FIRMWARE_VERSION, onArduinoStartup);
arduino.requestFirmwareVersion();

// Arduino initialization
function onArduinoStartup(e:ArduinoEvent):void {
	arduino.setAnalogPinReporting(inputPin, Arduino.ON);
	trace(inputPin, " set to on");
	//sets ledPin to OUtput, with initia value of HIGH
	arduino.setPinMode(ledPin, Arduino.OUTPUT);
	trace(ledPin, " set to output");
	
	arduino.addEventListener(ArduinoEvent.ANALOG_DATA, onReceiveAnalogData);

	trace("Arduino initialized, actively listening for data");
}
	
		 



function onReceiveAnalogData(e:ArduinoEvent):void {
	trace("received", e.value);
	if(e.pin==inputPin) {
		if (state==0 && e.value != 0){ 
			trace("high");
			arduino.writeDigitalPin(ledPin, Arduino.HIGH);
			state = 1
		} else {
			trace("low");
			arduino.writeDigitalPin(ledPin, Arduino.LOW);
			state = 0
		}
	}
}	
trace("hlelo");
circle.visible=false;


