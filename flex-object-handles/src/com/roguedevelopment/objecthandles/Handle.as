

/*

Usage of this class is being deprecated.  We're just always going to use an ImageHandle so there's
a single set of code to maintain.  The default "image" looks nearly identical to what this handle
used to draw.

*/
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
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
 * This class represents one of the small boxes drawn around the object that can be dragged to resize or rotate
 **/
package com.roguedevelopment.objecthandles
{
	import mx.core.UIComponent;
	import flash.events.MouseEvent;
	import flash.events.Event;

	public class Handle extends UIComponent
	{
	
		
		// Does this handle let us resize down?
		public var resizeDown:Boolean = false;
		
		// Does this handle let us resize up?
		public var resizeUp:Boolean = false;
		
		// Does this handle let us resize left?
		public var resizeLeft:Boolean = false;
		
		// Does this handle let us resize to the right?
		public var resizeRight:Boolean = false;
		
		protected var _rotate:Boolean;
		public function set rotate(val:Boolean):void { _rotate=val; draw(); }
		public function get rotate():Boolean { return _rotate;  }		

		public function Handle()
		{
			super();
			width = 4;
			height = 4;
		}
		
		protected function draw() : void
		{
			graphics.clear();
			// TODO: Draw prettier handles.
			if( rotate )
			{
				graphics.lineStyle(1,0x888888);
				graphics.beginFill(0x888888,0.3);
				graphics.drawCircle(0,0,4);
				graphics.moveTo(-2,0);
				graphics.lineTo(-28,0);
				graphics.endFill();				
			}
			else
			{
				graphics.lineStyle(1,0x888888);
				graphics.beginFill(0x888888,0.3);
				graphics.drawRect(0,0,4,4);
				graphics.endFill();
			}
		}
		
		/**
		 * Returns true if this handle represents a handle in a corner.
		 **/
		public function isCorner() : Boolean
		{
			 return 2 == (  ( resizeUp ? 1 : 0 ) +
					 		( resizeDown ? 1 : 0 ) +
							( resizeLeft ? 1 : 0 ) +
							( resizeRight ? 1 : 0 ) ); // Corners can resize in exactly 2 directions.
		} 
		
		public function getCursorName() : String
		{
			if( !resizeDown && resizeLeft && !resizeRight && resizeUp )
			{
				return "SizeNWSE";
			}
			if( resizeDown && !resizeLeft && resizeRight && !resizeUp )
			{
				return "SizeNWSE";
			}
			if( !resizeDown && !resizeLeft && resizeRight && resizeUp )
			{
				return "SizeNESW";
			}
			if( resizeDown && resizeLeft && !resizeRight && !resizeUp )
			{
				return "SizeNESW";
			}
			if( resizeDown && !resizeLeft && !resizeRight && !resizeUp )
			{
				return "SizeNS";	
			}
			if( !resizeDown && !resizeLeft && !resizeRight && resizeUp )
			{
				return "SizeNS";	
			}
			if( !resizeDown && resizeLeft && !resizeRight && !resizeUp )
			{
				return "SizeWE";
			}
			if( !resizeDown && !resizeLeft && resizeRight && !resizeUp )
			{
				return "SizeWE";
			}
			
			if( rotate )
			{
				return "SizeAll";
			}
			return "";
		}
		

	}
}