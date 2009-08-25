package com.roguedevelopment.objecthandles
{
	import com.roguedevelopment.objecthandles.Handle;

	public class CircleHandle extends Handle
	{
		public function CircleHandle()
		{
			super();
		}
	
		override public function redraw():void
		{
			graphics.clear();
			if( isOver )
			{
				graphics.lineStyle(1,0x3dff40);
				graphics.beginFill(0xc5ffc0	,1);				
			}
			else
			{
				graphics.lineStyle(1,0);
				graphics.beginFill(0x51ffee,1);
			}
			
			graphics.drawCircle(7,7,5);
			graphics.endFill();
		}
		
	}
}