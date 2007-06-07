/**
 *  Latest information on this project can be found at http://www.rogue-development.com/objectHandles.xml
 *
 *  Copyright (c) 2007 Marc Hughes
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the Software
 *  is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 *  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 *  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 *  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *
 *
 **/

/**
 * This class represents the events that can be dispatched by the ObjectHandles class.
 * 
 * These events are dispatched on the completion of a user gesture.  So if a user slowly resizes
 * an object over a long distance, only one event is dispatched at the end of that action.
 * 
 * For resizing to the left or up, both move and resize events are dispatched.
 * 
 **/
package com.roguedevelopment.objecthandles
{
	import flash.events.Event;

	public class ObjectHandleEvent extends Event
	{
	
		/** Dispatched once a move action has completed.
		 **/
		public static const OBJECT_MOVED_EVENT:String = "objectMovedEvent";
		
		/** Dispatched once a resize action has completed.
		 **/
		public static const OBJECT_RESIZED_EVENT:String = "objectResizedEvent";
		
		/** Dispatched while the object is resizing for each incremental resize.
		 **/
		public static const OBJECT_RESIZING_EVENT:String = "objectResizingEvent";

		/** Dispatched once a resize action has completed.
		 **/
		public static const OBJECT_ROTATED_EVENT:String = "objectRotatedEvent";
		
		/** Dispatched while the object is resizing for each incremental resize.
		 **/
		public static const OBJECT_ROTATING_EVENT:String = "objectRotatingEvent";

		
		/** Dispatched while the object is moving for each incremental move.
		 **/
		public static const OBJECT_MOVING_EVENT:String = "objectMovingEvent";		
		
		/** 
		 * Dispatched when the user selects the object.
		 **/
		public static const OBJECT_SELECTED:String = "objectSelected";
		
		/** Dispatched when the user deselects the object.
		 **/
		public static const OBJECT_DESELECTED:String = "objectDeselected";

		public function ObjectHandleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}