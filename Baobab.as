package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class Baobab extends MovieClip {
		
		private var lifetime : int;
		private var birth : int;
		public var harvestable : Boolean;
		public var zid : int;
		private var isPaused : Boolean = false;
		private var pauseTime : int;
		
		public function Baobab(lifetime : int, depth:int) {
			// constructor code
			this.lifetime = lifetime;
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			this.birth = (new Date()).time;
			this.harvestable = true;
			this.zid = depth;
			
		}
		
		public function pause(){
			this.isPaused = true;
			this.pauseTime = (new Date()).time;
			this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		public function unpause(){
			this.isPaused = false;
			var delta:int = (new Date()).time - this.pauseTime;
			this.birth += delta;
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		public function updateDepth(depth:int){
			this.zid = depth;
		}
		
		public function onEnterFrame(e:Event){
			if (!this.harvestable){
				this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
				return;
			}
			var snap:int = (new Date()).time;
			
			var frm:int = int(25 * Number(snap-this.birth)/this.lifetime);
			
			if(frm>=25){
				this.gotoAndStop(25);
				this.harvestable = false;
				return;
			}else{
				this.gotoAndStop(frm);
			}
		}
		
		public function deplant(){
			this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			this.gotoAndPlay(30);
		}
		
	}
	
}
