package  {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	public class Overlay extends MovieClip {
		private var loader : GameLoader;
		private var calibrators : Vector.<Calibrator>;
		private var activated : Boolean;
		private var inputLength : int;
		private var activeSet : Object;
		public function Overlay(loader:GameLoader) {
			// constructor code
			this.x = 0;
			this.y = 0;
			this.alpha = 0;
			this.loader = loader;
			this.activated = false;
			this.inputLength = Math.min(this.loader.keyboardEmulators.length, this.loader.baobabPositions.length);
			this.calibrators = new Vector.<Calibrator>();
			this.activeSet = new Object();
			
			for (var i:int=0; i<this.loader.baobabPositions.length; i++){
				var n:Calibrator = new Calibrator(i,this.loader, this.loader.keyboardEmulators.charAt(i));
				n.x = this.loader.baobabPositions[i].x;
				n.y = this.loader.baobabPositions[i].y;
				this.addChild(n);
				this.calibrators.push(n);
			}
		}
		
		public function handleKeyDown(e:KeyboardEvent):void{
			trace("keydown!!!");
			if(this.activated){
				for(var i=0;i<this.inputLength;i++){
					if(e.charCode == this.loader.keyboardEmulators.charCodeAt(i) && !this.activeSet.hasOwnProperty(i)){
						this.calibrators[i].actuate();
						this.loader.handler.onBaobabActuation(i);
						this.activeSet[i] = true;
					}
				}
			}
		}
		
		public function handleKeyUp(e:KeyboardEvent):void{
			trace("keyup!!!");
			if(e.keyCode==86 && e.ctrlKey){
				if(this.activated){
					this.deactivate();
					this.activated = false;
				}else{
					this.activate();
					this.activated = true;
				}
			}
			if(this.activated){
				for(var i=0;i<this.inputLength;i++){
					if(e.charCode == this.loader.keyboardEmulators.charCodeAt(i)){
						this.calibrators[i].deactuate();
						this.loader.handler.onBaobabDeactuation(i);
						delete this.activeSet[i];
					}
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
