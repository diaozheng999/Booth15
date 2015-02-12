package  {
	import flash.events.Event;
	public class ArduinoInputEvent extends Event{

		public static const BTN_ON = "buttonOn";
		public static const BTN_OFF = "buttonOff";
		
		
		public var trigger:int;
		
		public function ArduinoInputEvent(type:String, trigger:int, bubbles:Boolean=true, cancelable:Boolean=false) {
			// constructor code
			super(type, bubbles, cancelable);
			this.trigger = trigger;
		}
		
		public override function clone():Event{
			return new ArduinoInputEvent(type, this.trigger, bubbles, cancelable)
		}
		
		

	}
	
}
