package com.roguedevelopment.objecthandles
{
	import flash.geom.Rectangle;
	
	public class DragGeometry
	{
		public var x:Number=0;
		public var y:Number=0;
		public var width:Number=0;
		public var height:Number=0;
		public var rotation:Number=0;

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