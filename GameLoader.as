package  {
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class GameLoader {
		
		private var handler : GameHandler;
		private var loader : URLLoader;
		public var arduino : Arduino;
		public var baobabPositions : Vector.<Coordinate>;
		private var readiness : Number = 0;
		
		
		private var inputPin : Number = 8;
		private var outputPin : Number = 13;
		
		
		public function GameLoader(handler : GameHandler) {
			// constructor code
			this.handler = handler;
			
			trace("Loading arduino...");
			this.arduino = new Arduino(5331);
			this.arduino.addEventListener(Event.CONNECT, this.onArduinoLoadComplete);
			this.arduino.connect();
			trace("Loading positions...");
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, this.onFileLoadComplete);
			this.loader.load(new URLRequest("baobabs.txt"));
		}
		
		
		public function onArduinoLoadComplete(evt : Event){
			this.getReady(1);
		}

		
		public function onFileLoadComplete(evt : Event){
			var data : Array = String(this.loader.data).split("\n");
			this.baobabPositions = new Vector.<Coordinate>();
			for each(var line in data){
				var coordinates : Array = String(line).split(",");
				this.baobabPositions.push(new Coordinate(Number(coordinates[0]),Number(coordinates[1])));
			}
			trace(this.baobabPositions);
			this.getReady(2);
		}
		
		private function getReady (code : Number) : void{
			this.readiness |= code;
			if (this.readiness==3){
				this.handler.onLoaderComplete();
			}
		}
		

	}
	
}
