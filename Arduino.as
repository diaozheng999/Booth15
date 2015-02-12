package  {
	import flash.net.Socket;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;

	public class Arduino extends EventDispatcher{
		private var socket : Socket;
		private var port : int;
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
			var t : String = (byte % 2==0) ? ArduinoInputEvent.BTN_ON : ArduinoInputEvent.BTN_OFF;
			var n : int = byte / 2;
			var e : ArduinoInputEvent = new ArduinoInputEvent(t, n);
			trace (e);
			this.dispatchEvent(e);
		}
	}
}
