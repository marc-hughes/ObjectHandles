package com.roguedevelopment.objecthandles
{
	import flash.events.MouseEvent;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 * A handle class based on SpriteVisualElement which is suitable for adding to
	 * a Flex 4 Group based container.
	 **/
	public class VisualElementHandle extends SpriteVisualElement implements IHandle
	{
		
		private var _descriptor:HandleDescription;		
		private var _targetModel:Object;
		protected var isOver:Boolean = false;
		
		public function get handleDescriptor():HandleDescription
		{
			return _descriptor;
		}
		public function set handleDescriptor(value:HandleDescription):void
		{
			_descriptor = value;
		}
		public function get targetModel():Object
		{
			return _targetModel;
		}
		public function set targetModel(value:Object):void
		{
			_targetModel = value;
		}
		
		public function VisualElementHandle()
		{
			super();
			addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			//redraw();
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
		
		public function redraw() : void
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
			
			graphics.drawRect(-5,-5,10,10);
			graphics.endFill();
			
		}
	}
}