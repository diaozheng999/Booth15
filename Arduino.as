package  {
	import flash.net.Socket;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class Arduino extends EventDispatcher{
		private var socket : Socket;
		private var port : int;
		private const INIT : int = 20;
		private const CLUSTER : int = 2;
		private const ON : int = 0;
		
		private var sensorStrength : Dictionary;
		
		public function Arduino (port : int) {
			// constructor code
			this.socket = new Socket();
			this.socket.addEventListener(Event.CONNECT, this.onConnect);
			this.port = port;
		}
		
		public function connect():void{			
			this.socket.connect("127.0.0.1", port);
		}
		
		private function onConnect(e:Event) : void{
			trace ("arduino connected.");
			this.socket.addEventListener(ProgressEvent.SOCKET_DATA, this.onData);
			this.dispatchEvent(e);
		}
		private function onData (e:ProgressEvent) : void{
			while(this.socket.bytesAvailable){
				this.processByte (this.socket.readByte());
			}
		}

		
		private function processByte (byte : int) : void{
			var sensor : int = byte / (2*this.CLUSTER);
			if(byte%2==this.ON){
				//button on
				if(!this.sensorStrength.hasOwnProperty(sensor)){
					this.sensorStrength[sensor] = 1;
					this.dispatchEvent(new ArduinoInputEvent(ArduinoInputEvent.BTN_ON, sensor));
				}else{
					this.sensorStrength[sensor]++;
				}
			}else{
				//button off
				if(this.sensorStrength.hasOwnProperty(sensor)){
					this.sensorStrength[sensor]--;
					if(this.sensorStrength[sensor]==0){
						delete this.sensorStrength[sensor];
						this.dispatchEvent(new ArduinoInputEvent(ArduinoInputEvent.BTN_OFF, sensor));
					}
				}
			}

		}
	}
}
