package  {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import net.eriksjodin.arduino.Arduino;
	import net.eriksjodin.arduino.events.ArduinoEvent;
	
	public class GameHandler {
		
		private var stage : Stage;
		private var arduino : Arduino;

		public function GameHandler(stage:Stage) {
			// constructor code
			this.stage = stage;
		}
		
		public function run() : void{
			this.arduino = new Arduino("127.0.0.1", 5331);
			
			arduino.addEventListener(ArduinoEvent.FIRMWARE_VERSION, this.onArduinoStartup);
			arduino.requestFirmwareVersion();
		}
		
		public function onArduinoStartup(event:ArduinoEvent) : void{
			trace("Arduino startup complete");
			var baobab : MovieClip = new Baobab();
			this.stage.addChild(baobab);
			baobab.x = this.stage.width/2;
			baobab.y = this.stage.height/2;
			baobab.gotoAndPlay(1);
			baobab.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		
		public function onEnterFrame(evt:Event) : void{
			evt.target.x += 1;
			evt.target.y += 1;
		}

	}
	
}
