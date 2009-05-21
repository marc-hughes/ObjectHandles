package com.roguedevelopment.objecthandles
{
	import flash.geom.Rectangle;
	
	public class DragGeometry
	{
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var rotation:Number;

		public function clone() : DragGeometry
		{
			var rv:DragGeometry = new DragGeometry();
			rv.x = x;
			rv.y = y;
			rv.width = width;
			rv.height = height;
			rv.rotation = rotation;
			return rv;
		}
		
		public function getRectangle() : Rectangle
		{
			return new Rectangle(x,y,width,height);
		}
	}
}