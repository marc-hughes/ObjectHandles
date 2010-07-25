/**
 *  Latest information on this project can be found at http://www.rogue-development.com/objectHandles.xml
 * 
 *  Copyright (c) 2008 Marc Hughes 
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
 * -------------------------------------------------------------------------------------------
 * 
 * Cursor graphics Copyright (C) Dunkelstern <jschriewer at arcor dot de> and released under an MIT license.
 * 
 **/

package com.roguedevelopment.objecthandles
{
	import flash.display.Loader;
	import mx.core.FlexSprite;
	import flash.utils.Dictionary;
	import flash.ui.Mouse;
	import mx.managers.CursorManager;
	import mx.controls.SWFLoader;
	import flash.events.Event;
	import flash.display.MovieClip;
	import mx.managers.PopUpManager;
	import mx.core.FlexMovieClip;
	import mx.core.UIComponent;
	import flash.events.MouseEvent;
	
	public class ObjectHandlesMouseCursors implements OHMouseCursors
	{
		[Embed("../../../assets/cursors/blue/SizeNS.png")]
		protected var sizeNS:Class;
		[Embed("../../../assets/cursors/blue/SizeAll.png")]
		protected var sizeAll:Class;
		[Embed("../../../assets/cursors/blue/SizeNESW.png")]
		protected var sizeNESW:Class;
		[Embed("../../../assets/cursors/blue/SizeNWSE.png")]
		protected var sizeNWSE:Class;
		[Embed("../../../assets/cursors/blue/SizeWE.png")]
		protected var sizeWE:Class;
	
		protected var map:Object = new Object();
		
		public function getCursor(name:String) : MouseCursorDetails
		{
			return map[name];
		}
		
		public function ObjectHandlesMouseCursors() : void
		{
			map["SizeNS"] = new MouseCursorDetails(sizeNS, -6, -15 );
			map["SizeAll"] = new MouseCursorDetails(sizeAll, -15, -15 );
			map["SizeNESW"] = new MouseCursorDetails(sizeNESW, -10, -10 );
			map["SizeNWSE"] = new MouseCursorDetails(sizeNWSE, -10, -10 );
			map["SizeWE"] = new MouseCursorDetails(sizeWE, -15, -6 );
		}
		
	}
}