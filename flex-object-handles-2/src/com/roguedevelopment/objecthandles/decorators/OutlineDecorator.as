package com.roguedevelopment.objecthandles.decorators
{
	import com.roguedevelopment.objecthandles.ObjectHandles;

	import flash.display.Sprite;

	/**
	 * This is an example decorator that draws a white border around all the selected objects.
	 **/
	public class OutlineDecorator implements IDecorator
	{
		/**
		 * Some global settings for the decorator. Set using class, not instance!!!
		 *
		 * Use to change the width border.
		 * usage: OutlineDecorator.lineWidth=1;
		 **/
		public static var lineWidth:Number = 5;

		/**
		 * Use to change the line color.
		 * usage: OutlineDecorator.lineColor=0xff0000;
		 **/
		public static var lineColor:int = 0xeeeeee;

		/**
		 * Use to change the line alpha.
		 * usage: OutlineDecorator.lineAlpha=0.6;
		 **/
		public static var lineAlpha:Number = 1;

		public function OutlineDecorator()
		{
		}

		protected function updateDecoration(selectedObjects:Array, drawingCanvas:Sprite):void
		{
			drawingCanvas.graphics.clear();
			drawingCanvas.graphics.lineStyle( lineWidth, lineColor, lineAlpha );

			for each ( var model:Object in selectedObjects )
			{
				drawingCanvas.graphics.drawRect( model.x, model.y, model.width, model.height );
			}
		}

		public function updateSelected( allObject:Array, selectedObjects:Array, drawingCanvas:Sprite ) : void
		{
			updateDecoration( selectedObjects, drawingCanvas );
		}
		public function updatePosition( allObject:Array, selectedObjects:Array, movedObjects:Array, drawingCanvas:Sprite ) : void
		{
			updateDecoration( selectedObjects, drawingCanvas );
		}
		public function cleanup(drawingCanvas:Sprite ):void
		{
			drawingCanvas.graphics.clear();
		}
	}
}