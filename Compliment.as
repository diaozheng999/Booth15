package  {
	
	import flash.display.MovieClip;
	
	
	public class Compliment extends MovieClip {
		
		public static const GOOD:int = 1;
		public static const EXCELLENT:int = 2;
		public static const AWESOME:int = 3;
		public static const SPECTACULAR:int = 4;
		public static const EXTRAODINARY:int = 5;
		public static const UNBELIEVABLE:int = 6;
		public function Compliment(compl:int) {
			// constructor code
			this.compliment.gotoAndStop(compl);
		}
	}
	
}
