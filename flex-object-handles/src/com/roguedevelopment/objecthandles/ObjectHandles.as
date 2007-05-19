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
 * -------------------------------------------------------------------------------------------
 * 
 * Description:
 *    ObjectHandles gives the user the ability to move and resize a component with the mouse.
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

	/** 
	 * The main component in the ObjectHandle package that provides most of the functionality.
	 **/
	public class ObjectHandles extends Canvas implements Selectable
	{	
		
		/** 
		 * Is the user allowed to vertically resize the component?
		 **/
		[Inspectable(defaultValue=true)]		
        public var allowVResize:Boolean = true;
        
		/** 
		 * Is the user allowed to horizontally resize the component?
		 **/
		[Inspectable(defaultValue=true)]		
        public var allowHResize:Boolean = true;
        
        /**
        * When resizing, should the component maintain aspect ratio?
        **/
		[Inspectable(defaultValue=true)]		
        public var maintainAspectRatio:Boolean = true;
        
        /** 
        * Is the component allowed to be moved vertically?
        **/
		[Inspectable(defaultValue=true)]		
        public var allowVMove:Boolean = true;
        
        /** 
        * Is the component allowed to be moved horizontally?
        **/
		[Inspectable(defaultValue=true)]		
        public var allowHMove:Boolean = true;
        
        /**
        * "anchors" the component to an X coordinate.
        * The component will be allowed to move left and right and resized horizontally, 
        * but some part of it must always cross the given X coordinate.
        * 
        * A value of -1 will cause this parameter to be ignored.
        **/
        [Inspectable(default=-1)]
        public var xAnchor:Number = -1;

        /**
        * "anchors" the component to Y coordinate.
        * The component will be allowed to move up and down and resized vertically, 
        * but some part of it must always cross the given Y coordinate.
        * 
        * A value of -1 will cause this parameter to be ignored.
        **/
        [Inspectable(default=-1)]
        public var yAnchor:Number = -1;
        
        
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
			
			creationPolicy = "all";
			
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
			
			parent.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			
			SelectionManager.instance.addSelectable(this);
		}
		
		protected function onMouseUp(event:MouseEvent) : void
		{
			if(wasResized )
			{
			    dispatchResized();
			}
			else if( wasMoved )
			{
				dispatchMoved();
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
		
		protected function dispatchMoving() : void
		{
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_MOVING_EVENT) );
		}

		protected function dispatchResizing() : void
		{
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_RESIZING_EVENT) );
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
					
			SelectionManager.instance.setSelected(this);
			
			// Add a stage listener in case the mouse up comes out of the control.
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp );
			
			var sp:Point = new Point(event.stageX, event.stageY);
			
			localClickPoint = globalToLocal( sp );
			
			var hits:Array = stage.getObjectsUnderPoint( sp );
			
			originalSize.x = width;
			originalSize.y = height;
			originalPosition.x = x;
			originalPosition.y = y;
			
			for each (var o:Object in hits)
			{
				var handleIndex:int = handles.indexOf(o);
				if( handleIndex >= 0)
				{
					if( handles[handleIndex] is Handle )
					{
						var handle:Handle = handles[handleIndex] as Handle;
						isResizingDown = handle.resizeDown;
						isResizingLeft = handle.resizeLeft;
						isResizingRight = handle.resizeRight;					
						isResizingUp = handle.resizeUp;
					}
					return;
				}				
			}
			
			isResizingDown = false;
			isResizingRight = false;
			isResizingUp = false;
			isResizingLeft = false;
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
			
			
			
			if( wasMoved ) { applyConstraints(); dispatchMoving() ; }
			if( wasResized ) { applyConstraints(); dispatchResizing() ; }
			
		}

		protected function showHandles( visible:Boolean ) : void
		{
			for each (var u:UIComponent in handles)
			{
				u.setVisible(visible);
			}			
		}
		
		/**
		 * On startup, creates the various handles that the user can interact with.
		 **/
		protected function createHandles() : Array
		{
			var handles:Array = new Array();
			// position ... top,left,bottom,right ... 1=on 
			var handleOptions:Array = [  {resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:false, style:{top:0, horizontalCenter:0 }},
			                             {resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:true,style:{top:0, left:0 }},
			                             {resizeUp:true, resizeDown:false, resizeRight:true, resizeLeft:false,style:{top:0, right:0}},
			                             {resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:false,style:{bottom:0, horizontalCenter:0 }},
			                             {resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:true,style:{bottom:0, left:0 }},
			                             {resizeUp:false, resizeDown:true, resizeRight:true, resizeLeft:false,style:{bottom:0, right:0}},
			                             {resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:true,style:{verticalCenter:0, left:0}},
			                             {resizeUp:false, resizeDown:false, resizeRight:true, resizeLeft:false,style:{verticalCenter:0, right:0}}
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
				
				var handle:Handle = new Handle();				
				handle.resizeDown = option.resizeDown;
				handle.resizeLeft = option.resizeLeft;
				handle.resizeRight = option.resizeRight;
				handle.resizeUp = option.resizeUp;
				handle.visible = false;
								
				for (var prop:String in option.style)
				{
	 				handle.setStyle(prop, option.style[prop] );	  	
	  			}
	  			
				addChild(handle);	
				trace(childDescriptors.length);
				handles.push(handle);		
			}										
			return handles;
		}		
		
		
		protected function applyConstraints():void
		{
			if( height < minHeight)
			{
				height = minHeight;
			}
			if( width < minWidth)
			{
				width = minWidth;
			}
			
			if( ! allowHMove )
			{
				x = originalPosition.x;
			}
			if( ! allowVMove )
			{
				y = originalPosition.y;
			}
			
			if( (xAnchor != -1 ) && (xAnchor < x) )
			{
				x = xAnchor;
			}

			if( (xAnchor != -1 ) && (xAnchor > (x+width)) )
			{
				x = xAnchor - width;
			}
			
			if( (yAnchor != -1 ) && (yAnchor < y) )
			{
				y = yAnchor;
			}

			if( (yAnchor != -1 ) && (yAnchor > (y+height)) )
			{
				y = yAnchor - height;
			}
		}
		
		public function select() : void
		{	
			showHandles(true);
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_SELECTED) );		
		}
		public function deselect() : void
		{
			showHandles(false);
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_DESELECTED) );		
		}
		
		

	}
	

	
}