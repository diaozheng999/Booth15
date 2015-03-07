package  {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	public class Overlay extends MovieClip {
		private var loader : GameLoader;
		private var calibrators : Vector.<Calibrator>;
		private var activated : Boolean;
		
		
		public function Overlay(loader:GameLoader) {
			// constructor code
			this.x = 0;
			this.y = 0;
			this.alpha = 0;
			this.loader = loader;
			this.activated = false;
			
			this.calibrators = new Vector.<Calibrator>();
			
			
			for (var i:int=0; i<this.loader.baobabPositions.length; i++){
				var n:Calibrator = new Calibrator(i,this.loader);
				n.x = this.loader.baobabPositions[i].x;
				n.y = this.loader.baobabPositions[i].y;
				this.addChild(n);
				this.calibrators.push(n);
			}
		}
		
		public function handleKeypress(e:KeyboardEvent):void{
			if(e.keyCode==86 && e.ctrlKey){
				if(this.activated){
					this.deactivate();
					this.activated = false;
				}else{
					this.activate();
					this.activated = true;
				}
			}
		}
		
		public function activate(){
			this.alpha = 1;
			for each(var n:Calibrator in this.calibrators){
				n.activate();
			}
		}
		
		public function deactivate(){
			this.alpha = 0;
			for each(var n:Calibrator in this.calibrators){
				n.deactivate();
			}
		}
		

	}
	
}
