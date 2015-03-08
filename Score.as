package  {
	
	import flash.display.MovieClip;
	
	
	public class Score extends MovieClip {
		
		
		public function Score() {
			// constructor code
			this.gotoAndStop(5);
			this.updateScore(0);
		}
		
		public function updateScore(sc:uint, suffix:String = ""){
			this.score.scoreTxt.text = sc.toString()+suffix;
			this.gotoAndPlay(1);
		}
	}
	
}
