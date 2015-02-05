package  {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	
	public class GameHandler {
		
		private var stage : Stage;

		public function GameHandler(stage:Stage) {
			// constructor code
			this.stage = stage;
		}
		
		public function run() : void{
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
