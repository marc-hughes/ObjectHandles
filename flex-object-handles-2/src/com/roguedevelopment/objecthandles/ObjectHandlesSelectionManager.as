package com.roguedevelopment.objecthandles
{
	import flash.events.EventDispatcher;
	
	[Event(name="removedFromSelection", type="com.roguedevelopment.objecthandles.SelectionEvent")]
	[Event(name="selectionCleared", type="com.roguedevelopment.objecthandles.SelectionEvent")]
	[Event(name="addedToSelection", type="com.roguedevelopment.objecthandles.SelectionEvent")]
	public class ObjectHandlesSelectionManager extends EventDispatcher
	{
		public var currentlySelected:Array = [];
		
		public function ObjectHandlesSelectionManager()
		{
		}
		
		public function addToSelected( model:Object ) : void
		{
			if( currentlySelected.indexOf( model ) != -1 ) { return; } // already selected
			
			currentlySelected.push(model);
			var event:SelectionEvent = new SelectionEvent( SelectionEvent.ADDED_TO_SELECTION );
			event.targets.push( model );
			dispatchEvent( event );
		}

		public function setSelected( model:Object ) : void
		{
			clearSelection();			
			addToSelected( model );			
		}
		
		public function removeFromSelected( model:Object ) : void
		{
			var ind:int = currentlySelected.indexOf(model);
			if( ind == -1 ) { return; }
			
			currentlySelected.splice(ind,1);
			
			var event:SelectionEvent = new SelectionEvent( SelectionEvent.REMOVED_FROM_SELECTION);
			event.targets.push(model);			
			dispatchEvent( event );
			
		}

		public function clearSelection(  ) : void
		{
			var event:SelectionEvent = new SelectionEvent( SelectionEvent.SELECTION_CLEARED );
			event.targets = currentlySelected;
			currentlySelected = [];						
			dispatchEvent( event );			
		}
		
		public function getGeometry() : DragGeometry
		{
			// TODO: handle multiple object selection
			if( currentlySelected.length == 0 ) { return null; }
			var obj:Object = currentlySelected[0];
			var rv:DragGeometry = new DragGeometry();
			
			if( obj.hasOwnProperty("x") ) rv.x = obj["x"];
			if( obj.hasOwnProperty("y") ) rv.y = obj["y"];
			if( obj.hasOwnProperty("width") ) rv.width = obj["width"];
			if( obj.hasOwnProperty("height") ) rv.height = obj["height"];
			if( obj.hasOwnProperty("rotation") ) rv.rotation = obj["rotation"];
			
			return rv;
		}


	}
}