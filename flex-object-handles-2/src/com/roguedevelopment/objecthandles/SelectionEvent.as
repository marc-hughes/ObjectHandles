package com.roguedevelopment.objecthandles
{
	import flash.events.Event;

	public class SelectionEvent extends Event
	{
		public static const REMOVED_FROM_SELECTION:String = "removedFromSelection";
		public static const SELECTION_CLEARED:String = "selectionCleared";
		public static const ADDED_TO_SELECTION:String = "addedToSelection";
		
		public var targets:Array = [];
		
		public function SelectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}