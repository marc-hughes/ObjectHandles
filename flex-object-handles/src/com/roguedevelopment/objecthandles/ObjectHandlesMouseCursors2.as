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
 * -------------------------------------------------------------------------------------------
 * 
 * Cursor graphics Copyright (C) Evi Skitsanos, contrubted to project.
 * 
 **/
package com.roguedevelopment.objecthandles
{
	public class ObjectHandlesMouseCursors2 implements OHMouseCursors
	{
		[Embed("../../../assets/cursors/set1/resize-v.png")]
		protected var sizeNS:Class;
		[Embed("../../../assets/cursors/set2/move.png")]
		protected var sizeAll:Class;
		[Embed("../../../assets/cursors/set1/resize-l.png")]
		protected var sizeNESW:Class;
		[Embed("../../../assets/cursors/set1/resize-r.png")]
		protected var sizeNWSE:Class;
		[Embed("../../../assets/cursors/set1/resize-h.png")]
		protected var sizeWE:Class;
	
		protected var map:Object = new Object();
		
		public function getCursor(name:String) : MouseCursorDetails
		{
			return map[name];
		}
		
		public function ObjectHandlesMouseCursors2() : void
		{
			map["SizeNS"] = new MouseCursorDetails(sizeNS, -5, -8 );
			map["SizeAll"] = new MouseCursorDetails(sizeAll, -11, -13 );
			map["SizeNWSE"] = new MouseCursorDetails(sizeNESW, -5, -6 );
			map["SizeNESW"] = new MouseCursorDetails(sizeNWSE, -5, -6 );
			map["SizeWE"] = new MouseCursorDetails(sizeWE, -9, -6 );
		}
	}
}