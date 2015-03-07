package  {
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	public class GameLoader {
		
		private var handler : GameHandler;
		private var loader : URLLoader;
		public var arduino : Arduino;
		public var currscore : int;
		public var baobabPositions : Vector.<Coordinate>;
		private var readiness : Number = 0;

		private var inputPin : Number = 8;
		private var outputPin : Number = 13;
		public var keyboardEmulators : String = "1234567890qwertyuiopasdfghjklzxcvbnm";
		
		
		public function GameLoader(handler : GameHandler) {
			// constructor code
			this.handler = handler;
			trace("Loading arduino...");
			this.arduino = new Arduino(5331);
			this.arduino.addEventListener(Event.CONNECT, this.onArduinoLoadComplete);
			this.arduino.connect();
			trace("Loading positions...");
			trace("Loading hiscores...");
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, this.onFileLoadComplete);
			this.loader.load(new URLRequest("baobabs.txt"));
			readHiscores();
		}
		
		public function onArduinoLoadComplete(evt : Event){
			this.getReady(1);
		}
		

		public function writeHiscores() : void {
			var score = this.handler.score;
	//		trace(score);
			var playerName = this.handler.playerName;
			if ({key:playerName , value:score} in this.handler.hiscores) {
				this.handler.hiscores.push({key:playerName,value:score});
			}


			
			var text = "";
			for each(var entry in this.handler.hiscores){
				text = text + entry.key + "," + entry.value.toString() + "\n";
			}
			var fileloc : String = File.applicationDirectory.resolvePath("hiscores.txt").nativePath;
			var file : File= new File(fileloc);
			var stream: FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(text);
			stream.close();
		}
		
		public function readHiscores() : void {
			this.handler.hiscores = new Array();
			var fileloc : String = File.applicationDirectory.resolvePath("hiscores.txt").nativePath;
			var filename : File= new File(fileloc);
			var filestream : FileStream = new FileStream();
			
			filestream.open(filename, FileMode.READ);
			
			var fulltext : String = "";
			
			while(filestream.bytesAvailable!=0){
				fulltext += filestream.readUTFBytes(1);
			}
			for each(var line in fulltext.split("\n")) {
				var nameandscore : Array = String(line).split(",");
				if (nameandscore[0] != "") {
					this.handler.hiscores.push({key:nameandscore[0],value: nameandscore[1]});
					//this.handler.hiscores[nameandscore[0]] = {key: nameandscore[0], value:int(nameandscore[1])};
				}
			}
		//	for each(var key in this.handler.hiscores) {
				//var value:int = this.handler.hiscores[key];
			//	trace(key.key+": "+key.value.toString());
			//}
		}
			
		
		public function onFileLoadComplete(evt : Event){
			var data : Array = String(this.loader.data).split("\n");
			this.baobabPositions = new Vector.<Coordinate>();
			for each(var line in data){
				var coordinates : Array = String(line).split(",");
				this.baobabPositions.push(new Coordinate(Number(coordinates[0]),Number(coordinates[1])));
			}
			trace(this.baobabPositions);
			readHiscores();
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
