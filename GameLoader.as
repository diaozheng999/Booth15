package  {
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import net.eriksjodin.arduino.Arduino;
	import net.eriksjodin.arduino.events.ArduinoEvent;
	
	public class GameLoader {
		
		private var handler : GameHandler;
		private var loader : URLLoader;
		public var arduino : Arduino;
		public var baobabPositions : Vector.<Coordinate>;
		private var readiness : Number = 0;
		
		public function GameLoader(handler : GameHandler) {
			// constructor code
			this.handler = handler;
			
			trace("Loading arduino...");
			this.arduino = new Arduino("127.0.0.1", 5331);
			this.arduino.addEventListener(ArduinoEvent.FIRMWARE_VERSION, this.onArduinoLoadComplete);
			this.arduino.requestFirmwareVersion();
			//read config
			trace("Loading positions...");
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, this.onFileLoadComplete);
			this.loader.load(new URLRequest("baobabs.txt"));
		}
		
		public function onArduinoLoadComplete(evt : ArduinoEvent){
			//do arduino code here
			this.readiness |= 1;
		}
		

		
		public function onFileLoadComplete(evt : Event){
			var data : Array = String(this.loader.data).split("\n");
			this.baobabPositions = new Vector.<Coordinate>();
			for each(var line in data){
				var coordinates : Array = String(line).split(",");
				this.baobabPositions.push(new Coordinate(Number(coordinates[0]),Number(coordinates[1])));
			}
			trace(this.baobabPositions);
			this.readiness |= 2;
		}
		
		private function getReady (code : Number) : void{
			this.readiness |= code;
			if (this.readiness==2){
				this.handler.onLoaderComplete();
			}
		}
		

	}
	
}
