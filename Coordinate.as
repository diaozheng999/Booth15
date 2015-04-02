package  {
	import flash.display.DisplayObject;
	
	public class Coordinate {
		public var x:Number;
		public var y:Number;
		
		public function Coordinate(x:Number, y:Number) {
			// constructor code
			this.x = x;
			this.y = y;
		}
		
		public function applyTo(obj : DisplayObject) {
			obj.x = this.x;
			obj.y = this.y;
		}
		
		public function toString():String{
			return x.toString()+","+y.toString();
		}
		
	

	}
	
}
