package com.roguedevelopment.popupbar
{
	import mx.controls.Button;
	import mx.collections.ArrayCollection;
	import flash.events.MouseEvent;
	import mx.events.FlexEvent;
	import mx.controls.Image;
	import mx.containers.HBox;
	import mx.core.ScrollPolicy;
	import mx.controls.List;
	import mx.containers.VBox;
	import mx.managers.PopUpManager;
	import flash.geom.Point;

	public class PopupBar extends HBox
	{
		 public var items:Array;
		
		[Bindable] public var selectedIndex:Number = 0;
		
		protected var image:Image;
		
		public function PopupBar()
		{
			super();
			
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			
			addEventListener(MouseEvent.CLICK, onClick );
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver );
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut );			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown );			
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp );			
						
			addEventListener(FlexEvent.CREATION_COMPLETE, init );
			
			mouseChildren=false;
			mouseEnabled=true;
			
			image = new Image();			
			addChild(image);
		}
		
		
		
		protected function init(event:FlexEvent) : void
		{
			setIcon("up");
		}
		
		protected function setIcon(state:String) : void
		{
			image.source = items[selectedIndex] + "_" + state + ".png";
			
		}
		
		protected function onClick(event:MouseEvent) : void
		{
			var list:VBox = new VBox();
			for each (var item:String in items)
			{
				var subImage:Image = new Image();
				subImage.source = item + "_up.png";
				list.addChild(subImage);
			}
					
						
			PopUpManager.addPopUp(list,this);
			var p:Point = localToGlobal(new Point(x,y) );
			list.x = p.x;
			list.y = p.y;
		}
		
		protected function onMouseDown(event:MouseEvent) : void
		{
			setIcon("dwn");			
		}
		
		protected function onMouseUp(event:MouseEvent) : void
		{
			setIcon("ovr");			
		}
		protected function onMouseOver(event:MouseEvent) : void
		{
			setIcon("ovr");			
		}
		protected function onMouseOut(event:MouseEvent) : void
		{
			setIcon("up");
		}
		
	}
}