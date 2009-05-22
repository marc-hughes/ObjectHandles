package com.roguedevelopment.objecthandles
{
	/**
	 * Constants defining what role(s) a given handle is for.
	 **/
	public class HandleRoles
	{
		public static const RESIZE_UP : uint = 1;
		public static const RESIZE_DOWN : uint = 2;
		public static const RESIZE_LEFT : uint = 4;
		public static const RESIZE_RIGHT : uint = 8;
		public static const ROTATE : uint = 16;
		public static const MOVE : uint = 32;
		
		
		// some convienence methods:
		
		public static function isResizeUp( val:uint ) : Boolean
		{
			return (val & RESIZE_UP) == RESIZE_UP;
		}
		public static function isResizeDown( val:uint ) : Boolean
		{
			return (val & RESIZE_DOWN) == RESIZE_DOWN;
		}
		public static function isResizeLeft( val:uint ) : Boolean
		{
			return (val & RESIZE_LEFT) == RESIZE_LEFT;
		}
		public static function isResizeRight( val:uint ) : Boolean
		{
			return (val & RESIZE_RIGHT) == RESIZE_RIGHT;
		}
		public static function isRotate( val:uint ) : Boolean
		{
			return (val & ROTATE) == ROTATE;
		}
		
		public static function isMove( val:uint ) : Boolean
		{
			return (val & MOVE) == MOVE;
		}
	}
}