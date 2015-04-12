package  {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.display.DisplayObject;
	import net.eriksjodin.arduino.events.ArduinoEvent;
	
	public class GameHandler {
		
		private var stage : Stage;
		private var arduino : Arduino;
		private var loader : GameLoader;
		private var overlay : Overlay;
		private var overlayWrapper : MovieClip;
		private var gameWrapper : MovieClip;
		private var scoreSprite : Score;
		private var multSprite : Score;
		private var pauseSprite : MovieClip;
		private var loadComplete : Boolean = false;
		private var mainTimeline;
		
		public function GameHandler(stage:Stage, gr:MovieClip, or:MovieClip, sc:Score, mt:Score, ps:MovieClip, tl) {
			// constructor code
			this.stage = stage;
			this.overlayWrapper = or;
			this.gameWrapper = gr;
			this.scoreSprite = sc;
			this.multSprite = mt;
			this.pauseSprite = ps;
			this.loader = new GameLoader(this);
			this.mainTimeline = tl;
			this.stage.nativeWindow.addEventListener(Event.CLOSING, this.loader.onClose);
		}
		
		
		public function updateSprites(gr:MovieClip=null, or:MovieClip=null,sc:Score=null,mt:Score=null, ps:MovieClip=null){
			if(gr!=null) this.gameWrapper = gr;
			if(or!=null) this.overlayWrapper = or;
			if(sc!=null) this.scoreSprite = sc;
			if(mt!=null) this.multSprite = mt;
			if(ps!=null) this.pauseSprite = ps;
			trace("update sprites: "+this.scoreSprite.name);
			trace("update sprites orig: "+sc);
			trace("update sprites orig: "+mt);
			
		}
		
		public function run() : void{
			this.startGame();
		}
		
		/*
		public function onArduinoStartup(event:ArduinoEvent) : void{
			trace("Arduino startup complete");
			var baobab : MovieClip = new Baobab();
			this.stage.addChild(baobab);
			baobab.x = this.stage.width/2;
			baobab.y = this.stage.height/2;
			baobab.gotoAndPlay(1);
			baobab.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}*/
		
		
		public function onEnterFrame(evt:Event) : void{
			evt.target.x += 1;
			evt.target.y += 1;
		}
		
		public function onLoaderComplete():void{
			trace("DONE!");
			this.arduino = this.loader.arduino;
			this.overlay = new Overlay(this.loader);
			this.overlayWrapper.addChild(this.overlay);
			this.loadComplete = true;
		}
		
		public function printBtn(e:ArduinoInputEvent):void{
			trace(e.type, e.trigger);
		}
		
		public var score : uint;
		public var multiplier : uint;
		public var tonextmult : uint;
		public var playerName : String;
		public var timer : Timer;
		public var level : int;
		public var hiscores : Array;
		public var concurrent : int;
		public var currTime : int;
		public var baobabs : Vector.<Baobab>;
		public var indicators : Vector.<Indicator>;
		public var freePositions : int;
		public var isRunning : Boolean = false;
		public var isPaused : Boolean = false;
		
		public var startScreen : MovieClip;
		public var stars:Vector.<BeginSprite>;
		
		
		public function getSpawnDelta(level:int):int{

			//if level<10{
			//	currTime = 1000 - int(level * 100);
			//	return currTime;
			//}
			var num = Number(level)+ 3;
			var delta = 3141.5926535 / Math.log(num);
			trace("level", level,": delay", delta);
			return int(delta);
		}
		public function getSpawnCount(level:int):int{
			trace("level", level,": count",3 + int( 0.5 * level ));
			return 3 + int( 0.5 * level);
		}
		
		public function drawStartScreen(){
			if(!this.loadComplete){
				var t:Timer = new Timer(100);
				var me = this;
				t.addEventListener(TimerEvent.TIMER, function(e){me.drawStartScreen();e.target.stop()});
				t.start();
				return;
			}
			this.startScreen = new MovieClip();
			this.stars = new Vector.<BeginSprite>();
			for(var i=0;i<this.loader.baobabPositions.length;i++){
				var star:BeginSprite = new BeginSprite();
				this.loader.baobabPositions[i].applyTo(star);
				this.startScreen.addChild(star);
				this.stars.push(star);
				
				if(star.y>=592){
					star.visible = false;
				}
			}
			this.overlayWrapper.addChild(this.startScreen);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, startGameKeyboardHandler);
			this.arduino.addEventListener(ArduinoInputEvent.BTN_OFF, startGameArduinoUpHandler);
			this.arduino.addEventListener(ArduinoInputEvent.BTN_ON, startGameArduinoDownHandler);
		}
		
		public function startGameArduinoDownHandler(e:ArduinoInputEvent){
			this.stars[e.trigger].gotoAndPlay(82);
		}
		
		public function startGameArduinoUpHandler(e:ArduinoInputEvent){
			this.onStartGame();
		}
		
		public function startGameKeyboardHandler(e:KeyboardEvent){
			if(e.keyCode==Keyboard.ENTER){
				this.onStartGame();
			}
		}
		
		public function onStartGame(){
			this.overlayWrapper.removeChild(this.startScreen);
			this.mainTimeline.gotoAndStop(11);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, startGameKeyboardHandler);
			this.arduino.removeEventListener(ArduinoInputEvent.BTN_OFF, startGameArduinoUpHandler);
			this.arduino.removeEventListener(ArduinoInputEvent.BTN_ON, startGameArduinoDownHandler);
		}
			
			
		public function startGame():void{
			trace("Starting game!");
			//adds event listeners
			this.score = 0;
			this.multiplier = 1;
			this.scoreSprite.updateScore(this.score);
			this.multSprite.updateScore(this.multiplier," x");
			this.tonextmult = 5;
			this.playerName = "Hello";
			this.isRunning = true;
			this.isPaused = false;
			trace("Player name is..", this.playerName);
			this.freePositions = this.loader.baobabPositions.length;
			this.concurrent = 1;
			
			for(var i=0;i<this.loader.baobabPositions.length;i++){
				var indicator:MovieClip = new MovieClip();
				indicator.x = 0;
				indicator.y = 0;
				indicator.name = "_CAP"+i;
				this.gameWrapper.addChild(indicator);
			}
			
			trace("Hello!");
			trace(this.gameWrapper.numChildren);
			
			this.baobabs = new Vector.<Baobab>();
			this.indicators = new Vector.<Indicator>();
			
			this.loader.baobabPositions.forEach(function(a,b,c){
				this.baobabs.push(null);
				this.indicators.push(null);
			}, this);
			trace(this.baobabs);
			this.spawnCountdown();
			this.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyRelease);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyPress);
		}
		
		public function spawnCountdown(){
			var q:Countdown = new Countdown();
			q.x = this.stage.width/2;
			q.y = this.stage.height/2;
			this.overlayWrapper.addChild(q);
			q.addEventListener(Event.COMPLETE, this.startTimer);
		}
		
		public function startTimer(e:Event){
			this.timer = new Timer(this.getSpawnDelta(0), this.getSpawnCount(0));
			this.timer.addEventListener(TimerEvent.TIMER, this.onTimerFired);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);
			this.arduino.addEventListener(ArduinoInputEvent.BTN_ON, this.handleArduinoEvent);
			this.arduino.addEventListener(ArduinoInputEvent.BTN_OFF, this.handleArduinoEvent);
			this.timer.start();
		}
		
		
		public function onKeyPress(e:KeyboardEvent){
			this.overlay.handleKeyDown(e);
			trace(e.keyCode);
			if(e.keyCode==38){
				this.incrementMult();
			}else if(e.keyCode==40){
				this.resetMultiplier();
			}
		}
		
		public function onKeyRelease(e:KeyboardEvent){
			this.overlay.handleKeyUp(e);
			if(e.keyCode == 32){
				this.onTimerFired(null);
			}else if(e.keyCode==80 && e.ctrlKey){
				this.togglePause();
			}
		}
		
		public function handleArduinoEvent(e:ArduinoInputEvent){
			this.printBtn(e);
			if(e.type==ArduinoInputEvent.BTN_ON){
				this.onBaobabActuation(e.trigger);
				this.overlay.handleArduinoDown(e);
			}else{
				this.overlay.handleArduinoUp(e);
				this.onBaobabDeactuation(e.trigger);
			}
		}
		
		public function random(min:int, max:int):int{
			return int(Math.random()*(max-min+1)+min);
		}
		
		public function onTimerFired(e:TimerEvent):void{
			if(!this.isRunning) return;
			trace("Planting baobab.", this.timer.currentCount);
			//var t:Baobab = new Baobab();
			var bpos : int = this.random(0,this.loader.baobabPositions.length-1);
			if(this.freePositions>0){
				while(this.baobabs[bpos]!=null){
					bpos = this.random(0,this.loader.baobabPositions.length-1);
				}
			}else{
				this.gameOver();
				return;
			}
			var pos : Coordinate = this.loader.baobabPositions[bpos];
			
			this.loader.baobabSpawn.play();
			var baobab : Baobab = new Baobab(25000, this.loader.baobabZBuffer[bpos]);
			baobab.x = pos.x;
			baobab.y = pos.y;
			this.baobabs[bpos] = baobab;
			trace(this.loader.baobabZBuffer[bpos]);
			trace(this.gameWrapper.numChildren);
			var q = this.gameWrapper.getChildAt(this.loader.baobabZBuffer[bpos]);
			q.addChild(baobab);
			this.freePositions--;
		}
		
		public function updateBaobabPositions(){
			for(var i=0;i<this.loader.baobabPositions.length;i++){
				if (this.baobabs[i]!=null){
					this.baobabs[i].parent.removeChild(this.baobabs[i]);
				}
			}
			
			for(var i=0;i<this.loader.baobabPositions.length;i++){
				if(this.baobabs[i]!=null){
					trace(this.loader.baobabZBuffer[i]);
					this.baobabs[i].updateDepth(this.loader.baobabZBuffer[i]);
					var q = this.gameWrapper.getChildAt(this.loader.baobabZBuffer[i]);
					q.addChild(this.baobabs[i]);
					var pos:Coordinate = this.loader.baobabPositions[i];
					this.baobabs[i].x = pos.x;
					this.baobabs[i].y = pos.y;
				}
			}
			this.loader.writeSpawnLocations();
		}
		
		public function incrementScore(id : int) {
			var value: int = int (1 +(25 - this.baobabs[id].currentFrame) / 5 );
			this.score = this.score+ value * this.multiplier;
			this.tonextmult--;
			trace(this.score, this.tonextmult);
			this.scoreSprite.updateScore(this.score);
		}
		public function incrementMult() {
			this.multiplier++;
			this.multSprite.updateScore(this.multiplier, " x");
			this.tonextmult = 5;
			switch(this.multiplier){
				case 5:
					this.overlayWrapper.addChild(new Compliment(Compliment.GOOD, this.loader));
					break;
				case 10:
					this.overlayWrapper.addChild(new Compliment(Compliment.EXCELLENT, this.loader));
					break;
				case 15:
					this.overlayWrapper.addChild(new Compliment(Compliment.AWESOME, this.loader));
					break;
				case 20:
					this.overlayWrapper.addChild(new Compliment(Compliment.SPECTACULAR, this.loader));
					break;
				case 25:
					this.overlayWrapper.addChild(new Compliment(Compliment.EXTRAODINARY, this.loader));
					break;
				case 30:
					this.overlayWrapper.addChild(new Compliment(Compliment.UNBELIEVABLE, this.loader));
			}
		}
		
		public function resetMultiplier() {
			this.multiplier = 1;
			this.multSprite.updateScore(this.multiplier, " x");
			this.tonextmult = 5;
		}
		
		public function onTimerComplete(e:TimerEvent):void{
			trace("Done.");
			if(!this.isRunning) return;
			this.level++;
			this.timer.removeEventListener(TimerEvent.TIMER, this.onTimerFired);
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);
			this.timer = new Timer(this.getSpawnDelta(this.level), this.getSpawnCount(this.level));
			this.timer.addEventListener(TimerEvent.TIMER, this.onTimerFired);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);
			this.timer.start();
		}
		
		
		public function togglePause(){
			if(!this.isRunning) return;
			if(this.isPaused){
				this.isPaused = false;
				this.pauseSprite.visible = false;
				this.spawnCountdown();
				for each (var baobab in this.baobabs){
					if(baobab!=null) baobab.unpause();
				}
			}else{
				this.isPaused = true;
				this.timer.removeEventListener(TimerEvent.TIMER, this.onTimerFired);
				this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);				
				this.arduino.removeEventListener(ArduinoInputEvent.BTN_ON, this.handleArduinoEvent);
				this.arduino.removeEventListener(ArduinoInputEvent.BTN_OFF, this.handleArduinoEvent);
				this.pauseSprite.visible = true;
				
				for each (var baobab in this.baobabs){
					if(baobab!=null) baobab.pause();
				}
			}
			
		}
		
		public function onBaobabActuation(id:int){
			var indicator:Indicator = new Indicator();
			var pos = this.loader.baobabPositions[id];
			indicator.x = pos.x;
			indicator.y = pos.y;
			this.overlayWrapper.addChild(indicator);
			this.indicators[id] = indicator;
			if(this.baobabs[id]!=null){ //If the baobab eists we wait till it finishes
				this.baobabs[id];
				indicator.addEventListener(Event.COMPLETE, this.onIndicatorAnimationComplete(id));
			}else{
				indicator.gotoAndPlay(44); // pressed wrong button, so reset multiplier
				resetMultiplier();
			}
			
		}
		
		public function onIndicatorAnimationComplete(id:int){
			var me = this;
			return function (e:Event){
				me.onBaobabDeactuation(id);
			}
		}
		
		public function onBaobabDeactuation(id:int){
			if(this.indicators[id]!=null){
				if(this.indicators[id].parent!=null){
					this.indicators[id].stop();
					this.overlayWrapper.removeChild(this.indicators[id]);
					if(this.indicators[id].animationComplete && this.baobabs[id]!=null){
						this.removeBaobab(id);
					} else if (this.baobabs[id]!=null) {
						resetMultiplier();
					}
				}else if(this.baobabs[id]!=null){
					this.removeBaobab(id);
				} 
				this.indicators[id]=null;
			}
		}
		
		public function removeBaobab(id:int){
			trace("BAOBABBBB I HATE YOU!!!");
			if(this.baobabs[id]!=null){
				this.loader.baobabPop.play();
				incrementScore(id);
				if (this.tonextmult == 0) {
					incrementMult();
				}
				this.baobabs[id].deplant();
				this.baobabs[id]= null;
				this.freePositions++;
			}
		}
		
		public function gameOver(){	
			trace("GAME OVER!");
			this.isRunning = false;
			trace(this.isRunning)
			//remove all gameplay handlers
			this.timer.removeEventListener(TimerEvent.TIMER, this.onTimerFired);
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);
			this.timer.stop();
			//remove all baobabs
			while(this.gameWrapper.numChildren>0){
				this.gameWrapper.removeChildAt(0);
			}
						
			this.arduino.removeEventListener(ArduinoInputEvent.BTN_ON, this.handleArduinoEvent);
			this.arduino.removeEventListener(ArduinoInputEvent.BTN_OFF, this.handleArduinoEvent);
			var q:MovieClip = new TransitionSprite();
			this.overlayWrapper.addChild(q);
			var p = this;
			q.addEventListener(Event.COMPLETE, function(e){p.mainTimeline.gotoAndPlay(6)});
		}
	}
}
