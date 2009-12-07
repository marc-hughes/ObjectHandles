package com.roguedevelopment.objecthandles.decorators
{
	import flash.display.Sprite;
	
	public class AlignmentDecorator implements IDecorator
	{
		public function AlignmentDecorator()
		{
		}
		
		
		public function updateSelected(allObject:Array, selectedObjects:Array, drawingCanvas:Sprite):void
		{
			drawingCanvas.graphics.clear();
		}
		
		public function updatePosition(allObject:Array, selectedObjects:Array, movedObjects:Array, drawingCanvas:Sprite):void
		{
			if( selectedObjects.length != 1 ) return;
			var o:Object = selectedObjects[0];
			drawingCanvas.graphics.clear();
			drawingCanvas.graphics.lineStyle(1,0x00aaaa,1);
			for each ( var other:Object in allObject )
			{
				if( other == o ) continue;
				if( o.x==other.x ) drawVerticalLine(other.x,drawingCanvas);
				if( o.y==other.y ) drawHorizontalLine(other.y,drawingCanvas);
				if( (o.x+o.width)==(other.x+other.width) ) drawVerticalLine(other.x+other.width,drawingCanvas);
				if( (o.y+o.height)==(other.y + other.height) ) drawHorizontalLine(other.y+other.height,drawingCanvas);

				if( o.x==(other.width+other.x) ) drawVerticalLine(o.x,drawingCanvas);
				if( o.y==(other.y+other.height) ) drawHorizontalLine(o.y,drawingCanvas);
				if( (o.x+o.width)==other.x ) drawVerticalLine(o.x+o.width,drawingCanvas);
				if( (o.y+o.height)==other.y ) drawHorizontalLine(o.y+o.height,drawingCanvas);

			}
			
		}

		
		protected function drawVerticalLine( x:Number, sprite:Sprite ) : void
		{
			sprite.graphics.moveTo(x,0);
			sprite.graphics.lineTo(x,3000);
		}
		protected function drawHorizontalLine( y:Number, sprite:Sprite ) : void
		{
			sprite.graphics.moveTo(0,y);
			sprite.graphics.lineTo(3000,y);
		}
		
		public function cleanup(drawingCanvas:Sprite):void
		{
			drawingCanvas.graphics.clear();
		}
	}
}