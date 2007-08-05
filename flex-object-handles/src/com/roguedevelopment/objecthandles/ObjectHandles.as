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
 * -------------------------------------------------------------------------------------------
 *  
 * Contributions by:
 *    Alexander Kludt
 *    Thomas Jakobi
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
	import mx.managers.CursorManager;
	import mx.core.Container;
	import mx.effects.Rotate;
	import flash.geom.Matrix;
	import mx.containers.HBox;
	import flash.display.DisplayObject;
	import mx.core.ScrollPolicy;

	/** 
	 * The main component in the ObjectHandle package that provides most of the functionality.
	 **/
	[Event(name="objectRotated", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectRotating", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectMoved", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectResized", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectSelected", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectDeselected", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectMoving", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectResizing", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]	
	public class ObjectHandles extends Canvas implements Selectable
	{	
		
		/** 
		 * Is the user allowed to vertically resize the component?
		 **/
		[Inspectable(defaultValue=true)]		
        public var allowVResize:Boolean = true;
        
        
		/** 
		 * Is the user allowed to rotate the component?
		 **/
		[Inspectable(defaultValue=true)]		
        public var allowRotate:Boolean = true;

       /**
        * When rotating, should the component be rotated by centerpoint?
        **/
		[Inspectable(defaultValue=true)]		
        public var rotateFromCenter:Boolean = true;
                
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
        
        
        /**
        * Static method so we only have a single cursor object in memory.
        **/
        protected static var defaultCursors:OHMouseCursors = new ObjectHandlesMouseCursors2();
        
        /** 
        * The mouse cursors to use.
        * 
        * To change the default mouse cursors, subclass ObjectHandlesMouseCursors and assign it here.
        **/
        public var mouseCursors:OHMouseCursors = defaultCursors;
        
        protected var wasMoved:Boolean = false;
        protected var wasResized:Boolean = false;
		protected var wasRotated:Boolean = false;            

		protected var handles:Array;
		
		protected var isRotating:Boolean = false;
		protected var isResizingDown:Boolean = false;
		protected var isResizingRight:Boolean = false;		
		protected var isResizingLeft:Boolean = false;
		protected var isResizingUp:Boolean = false;		
		protected var isMoving:Boolean = false;
		
		protected var localClickPoint:Point = new Point();
		protected var localClickRotation:Number = 0;
		protected var localClickAngle:Number = 0;
		
		protected var originalPosition:Point = new Point();
		protected var originalSize:Point = new Point();		
		protected var originalRotation:Number = 0;
		
		protected var currentCursor:MouseCursorDetails = null;
		protected var currentCursorId:int = -1;
		
		protected var rotateEffect:Rotate;
		
		public function ObjectHandles()
		{
			super();
			
			creationPolicy = "all";
			mouseChildren = false;
			mouseEnabled = true;
			buttonMode = false;
			addEventListener( FlexEvent.CREATION_COMPLETE, init );						
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			
		}
		
		protected function init(event:FlexEvent) : void
		{
			handles = createHandles();
			
			rotateEffect = new Rotate();
						
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, onMouseUp );		
			
			addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );			
			addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			
			if(parent != null )
			{
				parent.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			}
			
			SelectionManager.instance.addSelectable(this);
		}
		
		
		protected function onMouseOver(event:MouseEvent) : void
		{
			if( ! event.buttonDown )
			{
				setMouseCursor(event.stageX, event.stageY);
			}
		}
		
		protected function setMouseCursor(x:Number, y:Number): void
		{
			if( mouseCursors == null ) {return;}
			if( parent == null ) {return;}
			var c:MouseCursorDetails;
			for each (var handle:Handle in handles )
			{
				if( handle.hitTestPoint( x,y ) )
				{					
					c = mouseCursors.getCursor(handle.getCursorName() );										
					if( c != currentCursor )
					{
						currentCursor = c;
						CursorManager.removeCursor(currentCursorId);
						currentCursorId = CursorManager.setCursor( c.cursor,2, c.offset.x, c.offset.y	 );						
					}					
					return;
				}
			}
			
			if( hitTestPoint(x,y) )
			{
				c = mouseCursors.getCursor("SizeAll");
				if( currentCursor != c )
				{
					currentCursor = c;
					CursorManager.removeCursor(currentCursorId);
					currentCursorId = CursorManager.setCursor( c.cursor,2, c.offset.x, c.offset.y	 );						
				}
				return;
			}
			
			currentCursor = null;
			CursorManager.removeCursor(currentCursorId);
		}
		protected function onMouseOut(event:MouseEvent) : void
		{
			if( ! event.buttonDown )
			{
				currentCursor = null;
				CursorManager.removeCursor(currentCursorId);
			}
		}
		
		protected function onMouseUp(event:MouseEvent) : void
		{
			if(wasRotated )
			{
			    dispatchRotated();
			}
			
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
			isRotating = false;
			isMoving = false;
			wasMoved = false
			wasResized = false;
			wasRotated = false;
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			
			setMouseCursor( event.stageX, event.stageY );
		}
		
		protected function dispatchRotating() : void
		{
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_ROTATING_EVENT) );
		}
		 
		protected function dispatchRotated() : void
		{
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_ROTATED_EVENT) );
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
			setMouseCursor(event.stageX, event.stageY );
					
			SelectionManager.instance.setSelected(this);
			
			// Add a stage listener in case the mouse up comes out of the control.
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp );
			
			var sp:Point = new Point(event.stageX, event.stageY);
			
			localClickPoint = globalToLocal( sp );
			localClickAngle = getMouseAngle();
			localClickRotation = rotation;
			
			//var hits:Array = stage.getObjectsUnderPoint( sp );
			
			originalSize.x = width;
			originalSize.y = height;
			originalPosition.x = x;
			originalPosition.y = y;
			
			for each (var handle:Handle in handles )
			{
				
					if( handle.hitTestPoint(event.stageX, event.stageY) )
					{						
						isResizingDown = handle.resizeDown;
						isResizingLeft = handle.resizeLeft;
						isResizingRight = handle.resizeRight;					
						isResizingUp = handle.resizeUp;
						isRotating = handle.rotate;
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
			if( ! visible ) { return; }
			
			if( ! event.buttonDown )
			{
				setMouseCursor( event.stageX, event.stageY );
				return;
			}

			if(parent == null )
			{
				return;
			}

			var dest:Point = parent.globalToLocal( new Point(event.stageX, event.stageY) );
			
			var desiredPos:Point = new Point();
			var desiredSize:Point = new Point();
			var desiredRotation:Number = 0;		
		
			
			if( parent is Canvas)
			{
				var parentCanvas:Canvas = parent as Canvas;
				dest.x += parentCanvas.horizontalScrollPosition;
				dest.y += parentCanvas.verticalScrollPosition;
			}
			
			desiredRotation = rotation;
			desiredSize.x = width;
			desiredSize.y = height;
			desiredPos.x = x;
			desiredPos.y = y;
			

			
			var bowAngle:Number = 0;//Math.PI / 180 * Math.abs(rotation);
			var theMatrix:Matrix;
			var rotatedPoint:Point;

			var xAlt:Number = localClickPoint.x;
			var yAlt:Number = localClickPoint.y;	
			
			var tX:Number = 0;
			var tP:Point = new Point();
			
			bowAngle = Math.PI / 180 * rotation * -1;						


			theMatrix = new Matrix(Math.cos(bowAngle), - Math.sin(bowAngle), Math.sin(bowAngle), Math.cos(bowAngle));
			rotatedPoint = theMatrix.transformPoint(new Point(xAlt, yAlt));
			
			if( isRotating && event.buttonDown)
			{		
				desiredRotation = Math.round(localClickRotation - localClickAngle + getMouseAngle());		
				wasRotated = true;
			}			
			
			if( isResizingRight && event.buttonDown)
			{				
				desiredSize.x = originalSize.x + globalToLocal( new Point(event.stageX, event.stageY)).x - localClickPoint.x ;
				wasResized = true;
			}
			if( isResizingDown && event.buttonDown)
			{				
				desiredSize.y = originalSize.y + globalToLocal( new Point(event.stageX, event.stageY)).y - localClickPoint.y ;
				wasResized = true;
			}
			if( isResizingLeft && event.buttonDown && rotation == 0)
			{	
				desiredPos.x = dest.x - localClickPoint.x;
				desiredSize.x = originalSize.x + (originalPosition.x - desiredPos.x);
				wasResized = true;
				wasMoved = true;
			}
			if( isResizingUp && event.buttonDown  && rotation == 0)
			{	
				desiredPos.y = dest.y - localClickPoint.y;
				desiredSize.y = originalSize.y + (originalPosition.y - desiredPos.y);												
				wasResized = true;
				wasMoved = true;
			}
						 
			
			if( isMoving && event.buttonDown)
			{
									
				desiredPos.y = dest.y - rotatedPoint.y;
				desiredPos.x = dest.x - rotatedPoint.x;

				
				wasMoved = true;			
			}
			
			
			
			if( wasMoved || wasResized )
			{
				applyConstraints(desiredPos,desiredSize);
				x = desiredPos.x;
				y = desiredPos.y
				width = desiredSize.x;
				height = desiredSize.y;
			}
			
			if(wasRotated){			
				
				if(rotateFromCenter){
					if(rotateEffect.isPlaying){
						rotateEffect.end();
					}
					rotateEffect = new Rotate();
					rotateEffect.target	   = this;
					rotateEffect.duration  = 1;
					rotateEffect.angleFrom = rotation;
					rotateEffect.angleTo   = desiredRotation;
					rotateEffect.originX   = width/2;
					rotateEffect.originY   = height/2;
					rotateEffect.play();
				}else{
					rotation = desiredRotation;
				}				
			}
			
			
			if( wasMoved ) {  dispatchMoving() ; }
			if( wasResized ) {  dispatchResizing() ; }
			if( wasRotated ) {dispatchRotating(); }
			
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
			var handleOptions:Array = [  {rotate:false, resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:false, style:{top:0, horizontalCenter:0 }},
			                             {rotate:false, resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:true,style:{top:0, left:0 }},
			                             {rotate:false, resizeUp:true, resizeDown:false, resizeRight:true, resizeLeft:false,style:{top:0, right:0}},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:false,style:{bottom:0, horizontalCenter:0 }},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:true,style:{bottom:0, left:0 }},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:true, resizeLeft:false,style:{bottom:0, right:0}},
			                             {rotate:false, resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:true,style:{verticalCenter:0, left:0}},
			                             {rotate:false, resizeUp:false, resizeDown:false, resizeRight:true, resizeLeft:false,style:{verticalCenter:0, right:0}},
			                             {rotate:true,  resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:false,style:{verticalCenter:2, right:-30}}
										];	
			
			for each (var option:Object in handleOptions)
			{
				if( (! allowRotate ) && option.rotate )				
				{
					continue;
				}
				if( (! allowHResize) && (option.resizeLeft || option.resizeRight) )
				{
					continue;					
				}

				if( (! allowVResize) && (option.resizeUp || option.resizeDown) )
				{
					continue;					
				}
				
				if( (! allowVMove) && option.resizeUp  )
				{
					continue;					
				}


				if( (! allowHMove) && option.resizeLeft  )
				{
					continue;					
				}
				
				var handle:Handle = new Handle();				
				handle.resizeDown = option.resizeDown;
				handle.resizeLeft = option.resizeLeft;
				handle.resizeRight = option.resizeRight;
				handle.resizeUp = option.resizeUp;
				handle.rotate = option.rotate;
				handle.visible = false;
				
								
				for (var prop:String in option.style)
				{
	 				handle.setStyle(prop, option.style[prop] );	  	
	  			}
	  			
				super.addChild(handle);	
				handles.push(handle);		
			}										
			return handles;
		}		
		
		
		protected function applyConstraints(desiredPositon:Point, desiredSize:Point):void
		{
			var diff:int;
			
			// Minimum height check
			if( desiredSize.y < minHeight)
			{
				diff = minHeight - desiredSize.y;
				desiredSize.y = minHeight;
				
				if( desiredPositon.y != y )
				{
					desiredPositon.y -= diff;
				}
				
			}
			
			// Minimum width check
			if( desiredSize.x < minWidth)
			{
				diff = minWidth - desiredSize.x;
				desiredSize.x = minWidth;
				
				if( desiredPositon.x != x )
				{
					desiredPositon.x -= diff;
				}
			}
			
			
			
			if( ! allowHMove )
			{
				desiredPositon.x = originalPosition.x;
			}
			if( ! allowVMove )
			{
				desiredPositon.y = originalPosition.y;
			}
			
			if( (yAnchor != -1 ) && (yAnchor < desiredPositon.y) )
			{
				diff = desiredPositon.y - yAnchor;
				desiredPositon.y = yAnchor;
												
				if( desiredSize.y != height )
				{
					desiredSize.y += diff;	
				}
			}

			if( (xAnchor != -1 ) && (xAnchor < desiredPositon.x) )
			{
				diff = desiredPositon.x - xAnchor;
				desiredPositon.x = xAnchor;
												
				if( desiredSize.x != width )
				{
					desiredSize.x += diff;	
				}
			}

			if( (xAnchor != -1 ) && (xAnchor > (desiredPositon.x + desiredSize.x)) )
			{
				diff = xAnchor - ( desiredPositon.x + desiredSize.x) ;																
				if( desiredSize.x != width )
				{
					desiredSize.x += diff;	
				}
				desiredPositon.x = xAnchor - desiredSize.x;
			}
			
			if( (yAnchor != -1 ) && (yAnchor > (desiredPositon.y + desiredSize.y)) )
			{
				diff = yAnchor - ( desiredPositon.y + desiredSize.y) ;																
				if( desiredSize.y != height )
				{
					desiredSize.y += diff;	
				}
				desiredPositon.y = yAnchor - desiredSize.y;
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
		
		protected function getMouseAngle():Number{
			return Math.atan2(parent.mouseY - y, parent.mouseX - x) * 180/Math.PI; 
		}

	}
	

	
}