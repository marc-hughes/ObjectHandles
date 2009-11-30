package com.roguedevelopment.objecthandles.example
{
	import flash.display.Sprite;
	
	import mx.events.PropertyChangeEvent;

	
	/** 
	 * This is an example and not part of the core ObjectHandles library. 
	 **/

	public class SimpleSpriteShape extends Sprite
	{
		protected var model:SimpleDataModel;
		public function SimpleSpriteShape(model:SimpleDataModel)
		{
			super();
			this.model = model;
			model.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			x = model.x;
			y = model.y;			
			redraw();
		}
		
		protected function onModelChange( event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "x": x = event.newValue as Number; break;
				case "y": y = event.newValue as Number; break;
				case "rotation": rotation = event.newValue as Number; break;
				case "width":  
				case "height": break;
				default: return;
			}
			redraw();
		}
		
		protected function redraw() : void
		{
			graphics.clear();
			graphics.lineStyle(1,0);
			graphics.beginFill(0xB3EAFF,1);
			graphics.drawRoundRect(0,0,model.width,model.height,0,0);
			graphics.endFill();
		}
		
		
	}
}