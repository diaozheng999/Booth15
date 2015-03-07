package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent
	import flash.events.Event;
	
	
	public class Calibrator extends MovieClip {
		
		
		public function Calibrator() {
			// constructor code
			trace("hell oworld");
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		public function onMouseDown(e:MouseEvent) : void {
			this.startDrag();
		}

		
		public function onMouseUp(e:MouseEvent) : void {
			this.stopDrag();			
		}
		
	}
	
}
