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
 * -------------------------------------------------------------------------------------------
 * 
 * 
 * 
 * 
 **/
 
package com.roguedevelopment.objecthandles
{
	public class SelectionManager
	{
		private static var _instance:SelectionManager;
		private var _items:Array = new Array();
		[Bindable]
		public var currentlySelected:Selectable = null;
		
		public static function  get instance() : SelectionManager
		{
			if( ! _instance ) { _instance = new SelectionManager(); }
			return _instance;
		}
		
		public function selectNone() : void
		{
			setSelected(null);
		}
		
		public function setSelected(obj:Selectable) : void
		{
			if( obj == currentlySelected ) { return; }
			
			if( currentlySelected != null )
			{ 
				currentlySelected.deselect(); 
			}
			
			currentlySelected = obj;
			
			if( obj != null )
			{
				currentlySelected.select();
			}
			

		}
		
		public function getItems():Array
		{
          return _items;
        }
        
		public function addSelectable(obj:Selectable) : void
		{
			var ind:int = _items.indexOf( obj );
			if( ind != -1 ) { return; }
			
			_items.push(obj);
		}
		
		public function removeSelectable( obj : Selectable ) : void
		{
			var ind:int = _items.indexOf( obj );
			if( ind == -1 ) { return; }
			_items.splice( ind	, 1 );
			
		}
	}
}