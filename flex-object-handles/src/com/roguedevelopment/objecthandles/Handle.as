package com.roguedevelopment.objecthandles
{
	import mx.core.UIComponent;

	public class Handle extends UIComponent
	{
		public var resizeDown:Boolean = false;
		public var resizeUp:Boolean = false;
		public var resizeLeft:Boolean = false;
		public var resizeRight:Boolean = false;
		
		public function Handle()
		{
			super();
			graphics.lineStyle(1,0x888888);
			graphics.beginFill(0x888888,0.3);
			graphics.drawRect(0,0,4,4);
			graphics.endFill();
			
			mouseEnabled = false;
		}
		
	}
}