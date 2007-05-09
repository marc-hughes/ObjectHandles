package com.roguedevelopment.objecthandles
{
	import flash.events.Event;

	public class ObjectHandleEvent extends Event
	{
		public static const OBJECT_MOVED_EVENT:String = "objectMovedEvent";
		public static const OBJECT_RESIZED_EVENT:String = "objectResizedEvent";
		
		public function ObjectHandleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}