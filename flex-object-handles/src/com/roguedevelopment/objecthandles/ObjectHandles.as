/**
 *  Latest information on this project can be found at http://www.rogue-development.com/objectHandles.xml
 * 
 *  Copyright (c) 2007 Marc Hughes 
 * 
 *  Permission is hereby granted, free of charge, to any person obtaining a 
 *  copy of this software and associated documentation files (the "Software"), 
 *  to deal in the Software without restriction, including without limitation 
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 *  and/or sell copies of the Software, and to permit persons to whom the Software 
 *  is furnished to do so, subject to the following conditions:
 * 
 *  The above copyright notice and this permission notice shall be included in all 
 *  copies or substantial portions of the Software.
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 *  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 *  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 *  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 *  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 * 
 * 
 * 
 **/
package com.roguedevelopment.objecthandles
{
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	import flash.events.MouseEvent;
	import mx.core.UIComponent;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;
	import flash.geom.Point;
	import flash.display.Stage;
	import flash.filters.GlowFilter;

	public class ObjectHandles extends Canvas
	{	
		/**
		 * When the mouse is hovering over the item, these filters will be set.
		 **/
		public var hoverFilters:Array = new Array();
		
		[Inspectable(defaultValue=true)]		
        public var allowVResize:Boolean = true;
        
		[Inspectable(defaultValue=true)]		
        public var allowHResize:Boolean = true;
        
		[Inspectable(defaultValue=true)]		
        public var maintainAspectRatio:Boolean = true;
        
		[Inspectable(defaultValue=true)]		
        public var allowVMove:Boolean = true;
        
		[Inspectable(defaultValue=true)]		
        public var allowHMove:Boolean = true;
        
        protected var wasMoved:Boolean = false;
        protected var wasResized:Boolean = false;
            
		protected var handles:Array;
		
		protected var isResizingDown:Boolean = false;
		protected var isResizingRight:Boolean = false;		
		protected var isResizingLeft:Boolean = false;
		protected var isResizingUp:Boolean = false;		
		protected var isMoving:Boolean = false;
		
		protected var localClickPoint:Point = new Point();
		protected var originalPosition:Point = new Point();
		protected var originalSize:Point = new Point();
		
		public function ObjectHandles()
		{
			super();
			mouseChildren = false;
			mouseEnabled = true;
			buttonMode = false;
			addEventListener( FlexEvent.CREATION_COMPLETE, init );	
		}
		
		protected function init(event:FlexEvent) : void
		{
			handles = createHandles();
		
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			
			addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			addEventListener( MouseEvent.MOUSE_OVER, onMouseHover );
			
			parent.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );


			
		}
		
		protected function onMouseUp(event:MouseEvent) : void
		{
			if( wasMoved )
			{
				dispatchMoved();
			}
			
			if(wasResized )
			{
				dispatchResized();
			}
			
			isResizingDown = false;
			isResizingRight = false;		
			isResizingLeft = false;
			isResizingUp = false;
			isMoving = false;
			wasMoved = false
			wasResized = false;
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		protected function dispatchMoved() : void
		{
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_MOVED_EVENT) );
		}
		protected function dispatchResized() : void
		{
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_RESIZED_EVENT) );
		}
		protected function onMouseDown(event:MouseEvent) : void
		{
			// Add a stage listener in case the mouse up comes out of the control.
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp );
			
			var hits:Array = getObjectsUnderPoint( new Point(event.stageX, event.stageY) );
			localClickPoint = globalToLocal( new Point(event.stageX, event.stageY) );
			originalSize.x = width;
			originalSize.y = height;
			originalPosition.x = x;
			originalPosition.y = y;
			
			for each (var o:Object in hits)
			{
				var handleIndex:int = handles.indexOf(o);
				if( handleIndex >= 0)
				{
					var handle:Handle = handles[handleIndex] as Handle;
					isResizingDown = handle.resizeDown;
					isResizingLeft = handle.resizeLeft;
					isResizingRight = handle.resizeRight;					
					isResizingUp = handle.resizeUp;
					return;
				}				
			}
			
			isResizingDown = false;
			isResizingRight = false;
			isMoving = true;
			
		}
		protected function onMouseMove(event:MouseEvent) : void
		{
			var dest:Point = parent.globalToLocal( new Point(event.stageX, event.stageY) );
			
			if( isResizingRight && event.buttonDown)
			{				
				width = originalSize.x + globalToLocal( new Point(event.stageX, event.stageY)).x - localClickPoint.x ;
				wasResized = true;
			}
			if( isResizingDown && event.buttonDown)
			{				
				height = originalSize.y + globalToLocal( new Point(event.stageX, event.stageY)).y - localClickPoint.y ;
				wasResized = true;
			}
			if( isResizingLeft && event.buttonDown)
			{		
				
				x = dest.x - localClickPoint.x;
				width = originalSize.x + (originalPosition.x - x);
				wasResized = true;
				wasMoved = true;
			}
			if( isResizingUp && event.buttonDown)
			{				
				
				y = dest.y - localClickPoint.y;
				height = originalSize.y + (originalPosition.y - y);												
				wasResized = true;
				wasMoved = true;
			}
						 
			
			if( isMoving && event.buttonDown)
			{
				
				x = dest.x - localClickPoint.x;
				y = dest.y - localClickPoint.y;	
				wasMoved = true;			
			}
			
			
			if( height < minHeight)
			{
				height = minHeight;
			}
			if( width < minWidth)
			{
				width = minWidth;
			}
			
		}
		protected function onMouseOut(event:MouseEvent) : void
		{
			if( event.buttonDown ){ return; }
			filters = [];
			for each (var u:UIComponent in handles)
			{
				
				u.setVisible(false);
			}
			
		}
		protected function onMouseHover(event:MouseEvent) : void
		{
			filters = hoverFilters;
			for each (var u:UIComponent in handles)
			{
				u.setVisible(true);
			}
			
		}
		
		protected function createHandles() : Array
		{
			var handles:Array = new Array();
			// position ... top,left,bottom,right ... 1=on 
			var handleOptions:Array = [  {resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:false, style:{top:0, horizontalCenter:-2 }},
			                             {resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:true,style:{top:0, left:0 }},
			                             {resizeUp:true, resizeDown:false, resizeRight:true, resizeLeft:false,style:{top:0, right:4}},
			                             {resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:false,style:{bottom:4, horizontalCenter:-2 }},
			                             {resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:true,style:{bottom:4, left:0 }},
			                             {resizeUp:false, resizeDown:true, resizeRight:true, resizeLeft:false,style:{bottom:4, right:4}},
			                             {resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:true,style:{verticalCenter:-2, left:0}},
			                             {resizeUp:false, resizeDown:false, resizeRight:true, resizeLeft:false,style:{verticalCenter:-2, right:4}}
										];	
			
			for each (var option:Object in handleOptions)
			{
				if( (! allowHResize) && (option.resizeLeft || option.resizeRight) )
				{
					continue;					
				}

				if( (! allowVResize) && (option.resizeUp || option.resizeDown) )
				{
					continue;					
				}
				
				var style:CSSStyleDeclaration = new CSSStyleDeclaration();
				
				var handle:Handle = new Handle();
				
				handle.resizeDown = option.resizeDown;
				handle.resizeLeft = option.resizeLeft;
				handle.resizeRight = option.resizeRight;
				handle.resizeUp = option.resizeUp;
				handle.visible = false;
				
				for (var prop:String in option.style)
				{
	 				style.setStyle(prop, option.style[prop] );	  	
	  			}
				handle.styleDeclaration = style;
				addChild(handle);	
				handles.push(handle);		
			}
										
			return handles;
		}
		
	}
}