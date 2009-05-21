package com.roguedevelopment.objecthandles
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class Handle extends Sprite
	{
		public var descriptor:HandleDescription;		
		public var targetModel:Object;
		protected var isOver:Boolean = false;
		
		public function Handle()
		{
			super();
			addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			redraw();
		}
		
		protected function onRollOut( event : MouseEvent ) : void
		{
			isOver = false;
			redraw();
		}
		protected function onRollOver( event:MouseEvent):void
		{
			isOver = true;
			redraw();
		}
		
		protected function redraw() : void
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
				graphics.beginFill(0xaaaaaa,1);
			}
			
			graphics.drawRect(0,0,10,10);
			graphics.endFill();
			
		}
		
	}
}