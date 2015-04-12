package  {
	
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	public class Score extends MovieClip {
		
		var _score:uint = 0;
		
		public function Score() {
			// constructor code
			this.gotoAndStop(5);
			this.updateScore(0);
			this._score = 0;
		}
		
		public function updateScore(sc:uint, suffix:String = ""){
			trace(this.name+": update score to "+sc.toString()+suffix);
			this.score.scoreTxt.text = sc.toString()+suffix;
			this._score = sc;
			this.gotoAndPlay(1);
		}
		
		public function stepTo(sc:uint, callback:Function){
			trace("stepTo.");
			var delta:uint, count:uint;
			if(sc-this._score>50){
				delta = (sc-this._score)/50;
				count = 50;
			}else{
				delta = 1;
				count = (sc-this._score);
			}
			var timer:Timer = new Timer(30,sc-this._score);
			var me = this;
			if(sc==_score){
				callback();
				return;
			}
			timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent){
				trace("stepTo step");
				if(me._score+delta>sc){
					me.updateScore(sc);
					callback();
					e.target.stop();
				}else{
					me.updateScore(me._score+delta);
				}
			});
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent){
				trace("stepTo complete");
				callback();
			});
			timer.start();
		}
	}
	
}
