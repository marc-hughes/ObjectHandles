package com.roguedevelopment.objecthandles.example
{
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;

	public class SimpleFlexShape extends UIComponent
	{
		protected var model:SimpleDataModel;
		
		public function SimpleFlexShape(model:SimpleDataModel)
		{
			super();
			this.model = model;
			redraw();
			x = model.x;
			y = model.y;
			model.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
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
			graphics.beginFill(0x555555,0.6);
			graphics.drawRoundRect(0,0,model.width,model.height,0,0);
			graphics.endFill();
		}
		
	}
}