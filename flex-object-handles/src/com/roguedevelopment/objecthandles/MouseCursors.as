package com.roguedevelopment.objecthandles
{
	import flash.display.Loader;
	import mx.core.FlexSprite;
	import flash.utils.Dictionary;
	import flash.ui.Mouse;
	import mx.managers.CursorManager;
	import mx.controls.SWFLoader;
	
	public class MouseCursors
	{
		private static var _instance:MouseCursors;
		private static var _loader:Loader;
		private var _cursors:Dictionary;
		
		public static function instance() : MouseCursors
		{
			if( ! _instance )
			{
				_instance = new MouseCursors();
			}
			return _instance;
		}
		
		public function setCursor( cursorName:String ) : void
		{
			
		}		
		
		public function MouseCursors()
		{			
			_cursors = new Dictionary();			
			var url:String = "mouse_cursor.swf";
			
		}
	}
}