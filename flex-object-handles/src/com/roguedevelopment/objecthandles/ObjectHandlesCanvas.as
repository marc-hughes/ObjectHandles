package com.roguedevelopment.objecthandles
{
	import flash.display.DisplayObject;
	
	import mx.containers.Canvas;
	import mx.managers.IFocusManagerComplexComponent;

	/**
	 * This class provides keyboard navigation to the ObjectHandles within it.
	 * 
	 * You don't have to use this to use ObjectHandles, but then you won't get keyboard nav.
	 * 
	 * TODO: visible=false object handles can still be tabbed to.
	 * 
	 **/
	public class ObjectHandlesCanvas extends Canvas implements IFocusManagerComplexComponent
	{
		protected var objectHandles:Array = [];
		
		protected var currentOH:ObjectHandles;
		
		public function ObjectHandlesCanvas()
		{
			super();
			tabChildren = false;
			tabEnabled = true;
			focusEnabled = true;
			
		}


		public function advanceFocus(from:ObjectHandles) : Boolean
		{
			return moveFocus( from, false );
		}
		protected function moveFocus( from:ObjectHandles, backwards:Boolean ) :Boolean
		{
			var items:Array = objectHandles.concat();
			items.sort( sortByPosition );
			
			
			
			var ind:int = items.indexOf( from );						
			if(backwards)
			{
				ind--;	
			}
			else
			{
				ind++;
			}
			if( ind == -1 ){ return false; }
			if( ind == -2 ){ ind = items.length-1; }
			if( ind >= items.length )
			{	
				return false;
			} 
			currentOH = items[ind] as ObjectHandles;
			items[ind].setKeyboardFocus();
			return true;
		}		
		
		override public function setFocus():void
		{
			advanceFocus(null);			
		}

		public function retreatFocus(from:ObjectHandles) : Boolean
		{
			return moveFocus( from, true );
		}		
		
		protected function sortByPosition( first:ObjectHandles, second:ObjectHandles ) : Number
		{
			if(first.y < second.y ) { return -1; }
			if(first.y > second.y ) { return 1; }	

			if(first.x < second.x ) { return -1; }
			if(first.x > second.x ) { return 1; }	
			
			return 0;
		}
		
		
		protected function sortChildren() : void
		{
			var i:int = 0;
			var sortedChildren:Array = [];
			for( i = 0 ; i < numChildren ; i++)
			{
				sortedChildren.push( getChildAt(i) );
			}
						
			sortedChildren.sort( comparator );
			i=0;
			for each ( var d:DisplayObject in sortedChildren )
			{
				setChildIndex(d, i );
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
		
		protected function comparator( obj1:Object , obj2:Object ) : Number
		{
			var so1:Number = obj1 is ObjectHandles ? 
										(obj1 as ObjectHandles).sortOrder :
										obj1.hasOwnProperty("sortOrder") ?
											obj1.sortOrder 
											: 0 ;
										
										
			var so2:Number = obj2 is ObjectHandles ? 
										(obj2 as ObjectHandles).sortOrder :
										obj2.hasOwnProperty("sortOrder") ?
											obj2.sortOrder 
											: 0 ;
											
			if( so1 > so2 ) { return 1; }
			if( so1 < so2 ) { return -1; }
			return 0;
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
		
		
		public function get hasFocusableContent():Boolean 
		{
			return objectHandles.length > 0;
		}
	
		public function assignFocus(direction:String):void
		{
			if( direction == "top" )
			{
				advanceFocus(null);				
			}
			else
			{
				retreatFocus(null);
			}
			
			// The first time we tab in, we also set that item selected.
			// After that, we only change focus.
			if( currentOH )
			{
				SelectionManager.instance.setSelected( currentOH );
			}
		}
		
	}
}