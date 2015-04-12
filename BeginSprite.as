package  {
	
	import flash.display.MovieClip;
	import flash.display.Loader;
	
	
	public class BeginSprite extends MovieClip {
		
		private var pos:uint;
		public function BeginSprite() {
			// constructor code
			this.rotation = this.random(0,360);
			var sc = random(0.5,1.2);
			trace(sc);
			trace(this.scaleX, this.scaleY);
			this.scaleX = sc;
			this.scaleY = sc;
			trace(this.scaleX, this.scaleY);
			this.gotoAndPlay(uint(this.random(0,80)));
		}
		
		public function random(min:Number, max:Number):Number{
			return (Math.random()*(max-min)+min);
		}
		
		
	}
	
}
