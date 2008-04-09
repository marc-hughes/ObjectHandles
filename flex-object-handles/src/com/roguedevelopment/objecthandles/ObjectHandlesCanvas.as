package com.roguedevelopment.objecthandles
{
	import flash.display.DisplayObject;
	
	import mx.containers.Canvas;

	/**
	 * This class provides keyboard navigation to the ObjectHandles within it.
	 * 
	 * You don't have to use this to use ObjectHandles, but then you won't get keyboard nav.
	 * 
	 **/
	public class ObjectHandlesCanvas extends Canvas
	{
		protected var objectHandles:Array = [];
		
		public function ObjectHandlesCanvas()
		{
			super();
		}
		
		protected function sortChildren() : void
		{
			objectHandles.sortOn("sortOrder");
			var i:int = 0;
			for each ( var oh:ObjectHandles in objectHandles )
			{
				setChildIndex(oh, i );
				i++;
			}
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if( (child is ObjectHandles ) && (objectHandles.indexOf(child) != -1) )
			{
				objectHandles.splice(objectHandles.indexOf(child),1);
			}
			super.removeChild(child);			
			return child;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if( child is ObjectHandles )
			{
				objectHandles.push(child);
			}
			
			super.addChildAt(child,index);
			sortChildren();	
			return child;
		}
		
	}
}