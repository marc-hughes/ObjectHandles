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
 * 	  Mario Ernst
 *    Aaron Winkler
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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.effects.Rotate;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;

	/** 
	 * The main component in the ObjectHandle package that provides most of the functionality.
	 **/
	[Event(name="objectRotatedEvent", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectRotatingEvent", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectMovedEvent", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectResizedEvent", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectSelected", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectDeselected", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectMovingEvent", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	[Event(name="objectResizingEvent", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]	
	public class ObjectHandles extends Canvas implements Selectable
	{					
		
		/** 
		 * Is the user allowed to vertically resize the component?
		 **/
		[Inspectable(defaultValue=true)]		
        public var allowVResize:Boolean = true;
        
        
        /**
        * When contained within an ObjectHandlesCanvas, the items will be sorted by this in the display list order
        * which affects their z ordering.
        * 
        * It's ok to have duplicate sortOrder properties, think of it more like a "level" than a strict order.
        **/
        public var sortOrder:Number = 0;
        
		/** 
		 * Is the user allowed to rotate the component?
		 **/
		[Inspectable(defaultValue=true)]		
        public var allowRotate:Boolean = false;

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
        * When moving or resizing, and the object is on an ObjectHandlesCanvas, should it be brought to the foreground during the operation?
        **/
		[Inspectable(defaultValue=false)]		
        public var autoBringForward:Boolean = false;
        
        
        /**
        * For partially transparent objects, set this to true and a hit-detection based on the bitmap image of the
        * object will take place instead of just detecting clicks within the bounding box.  This is more CPU intensive so
        * only use it if you need to.
        **/
        [Inspectable(defaultValue=false)]
        public var pixelExactClick:Boolean = false;
        protected var listenAllLayers:Boolean = true; // I need to understand this more, why would we ever want it false?
        
        
        
        /**
        * An embedded image to use for the resize handles.
        * If you leave this null it will be programatically drawn.
        **/
        [Inspectable]
        public var resizeHandleImage:Class = null;
        
        /**
        * An embedded image to use for the rotate handles.
        * If you leave this null it will be programatically drawn.
        **/
        [Inspectable]
        public var rotateHandleImage:Class = null;

        
		/**
        * When resizing, should the component always maintain aspect ratio?
        **/
		[Inspectable(defaultValue=false)]		
		public var alwaysMaintainAspectRatio:Boolean = false;
        
        /**
        * When resizing, should the component maintain aspect ratio when a corner is dragged?
        **/
        [Inspectable(defaultValue=false)]
		public var cornerMaintainAspectRatio:Boolean = false;        
        
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
        
        protected var originalDepth:int;
        ﻿protected var aspectRatio:Number = 0;
        
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
		
		﻿protected var isCorner:Boolean = false;
		
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
			if (clipContent) {
				clipContent = resizeHandleImage == null;			
			}			
						
			
			handles = createHandles();
			
			rotateEffect = new Rotate();
						
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, onMouseUp );		
			
			addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );			
			addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			
			
			addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			
			SelectionManager.instance.addSelectable(this);
		}
		
		protected function switchToLocalMouseListener() : void
		{
			if( stage ) stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		}
		protected function switchToGlobalMouseListener() : void
		{
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
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
						cursorManager.removeCursor(currentCursorId);
						currentCursorId = cursorManager.setCursor( c.cursor,2, c.offset.x, c.offset.y	 );						
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
					cursorManager.removeCursor(currentCursorId);
					currentCursorId = cursorManager.setCursor( c.cursor,2, c.offset.x, c.offset.y	 );						
				}
				return;
			}
			
			currentCursor = null;
			cursorManager.removeCursor(currentCursorId);
		}
		protected function onMouseOut(event:MouseEvent) : void
		{
			if( ! event.buttonDown )
			{
				currentCursor = null;
				cursorManager.removeCursor(currentCursorId);
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
			
			if( stage ) stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			
			switchToLocalMouseListener();
			
			//setMouseCursor( stage.mouseX, stage.mouseX );
			setMouseCursor( event.stageX, event.stageY );
			resetZOrder();
		}
		
		protected function bringUp() : void
		{
			if( ! autoBringForward ) { return; }
			if( parent is ObjectHandlesCanvas )
			{
				try
				{
					originalDepth = parent.getChildIndex(this);
					trace("Original: " + originalDepth );
					if( originalDepth != parent.numChildren )
					{
						parent.setChildIndex( this, parent.numChildren -1 );
						trace("numchildren: " + parent.numChildren + " " + parent.getChildIndex(this));
					}
				}
				catch(e:Error)
				{
					trace("WARNING: ObjectHandles failed to bring the object forward.");
				}
			}			
		}
		
		protected function resetZOrder() : void
		{
			if( ! autoBringForward ) { return; }
			if( parent is ObjectHandlesCanvas )
			{
				try
				{	
					if( parent.getChildIndex(this) != originalDepth )
					{			 
						parent.setChildIndex( this, originalDepth );
					}
				}
				catch(e:Error)
				{
					trace("WARNING: ObjectHandles failed to reset the Z order.");
				}
			}			
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
			﻿if( height == 0 )
			{
				aspectRatio = 999; // You probably want to set a minimum size to prevent this.			  	
			}
			else
			{
				aspectRatio = width / height;
			}
			
			    //Only consider pixel exact mouse hits
                       if(pixelExactClick)
                       {

                               // Copy content of this Instance
                               var copyData:BitmapData = new BitmapData(width, height, true, 0x00000000);
                               copyData.draw(this);

                               // Get hit pixel
                               var pixel:uint = copyData.getPixel(event.localX, event.localY);

                               // If pixel is transparent
                               if( (pixel & 0xFF000000) == 0x00000000)
                               {

                                       // If Event should be bubbled to other Selectables
                                       if(listenAllLayers)
                                       {

                                               // All Selectables registered to the SelectionManager
                                               var selectables:Array = SelectionManager.instance.getItems();

                                               for each(var h:DisplayObject in selectables){

                                                       // Don't check for this instance
                                                       if(﻿(h is DisplayObject) && (h != this) ){
                                                       	
                                                       			﻿if( (h.width <= 0) || (h.height <= 0) ) { continue; }

                                                               var selectableCopyData:BitmapData = new BitmapData(h.width, h.height, true, 0x00000000);
                                                               selectableCopyData.draw(h);

                                                               // Convert Clickpoint for other selectable
                                                               var globalClickPoint:Point = new Point(event.stageX, event.stageY);
                                                               var handleClickPoint:Point = h.globalToLocal(globalClickPoint);

                                                               var selectablePixel:uint = selectableCopyData.getPixel(handleClickPoint.x, handleClickPoint.y);

                                                               if(selectablePixel != 0x00000000){

                                                                       // Now create a new event
                                                                       var e:MouseEvent = event.clone() as MouseEvent;
                                                                       // Correct the local Clickpoint of the event
                                                                       var hPoint:Point = new Point(event.stageX, event.stageY);
                                                                       var nPoint:Point = h.globalToLocal(hPoint);

                                                                       e.localX = nPoint.x;
                                                                       e.localY = nPoint.y;

                                                                       // Dispatch the event
                                                                       ﻿if( h is ObjectHandles )
                                                                       {
                                                                       	 (h as ObjectHandles).dispatchEvent(e);
                                                                       }
                                                                       // Don't process further
                                                                       return;
                                                               }


                                                       }

                                               }

                                       }

                                       return;
                               }

                       }

             
			setMouseCursor(event.stageX, event.stageY );
					
			SelectionManager.instance.setSelected(this);
			
			// Add a stage listener in case the mouse up comes out of the control.
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp );
			
			switchToGlobalMouseListener();
			
			var sp:Point = new Point(event.stageX, event.stageY);
			
			localClickPoint = globalToLocal( sp );
			localClickAngle = getMouseAngle();
			localClickRotation = rotation;
			
			//var hits:Array = stage.getObjectsUnderPoint( sp );
			
			originalSize.x = width;
			originalSize.y = height;
			originalPosition.x = x;
			originalPosition.y = y;
			
			bringUp();
			
			for each (var handle:Handle in handles )
			{
				
					if( handle.hitTestPoint(event.stageX, event.stageY) )
					{				
						﻿isCorner = handle.isCorner();					
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
			
			if( (wasResized && alwaysMaintainAspectRatio ) ||
				(wasResized && ( isCorner && cornerMaintainAspectRatio) ) )
			{				
				desiredSize.x = aspectRatio * desiredSize.y;
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
			
			event.updateAfterEvent();
			
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
			var defaultHandleOptions:Array = [  {rotate:false, resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:false, style:{top:0, horizontalCenter:0 }},
			                             {rotate:false, resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:true,style:{top:0, left:0 }},
			                             {rotate:false, resizeUp:true, resizeDown:false, resizeRight:true, resizeLeft:false,style:{top:0, right:0}},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:false,style:{bottom:0, horizontalCenter:0 }},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:true,style:{bottom:0, left:0 }},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:true, resizeLeft:false,style:{bottom:0, right:0}},
			                             {rotate:false, resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:true,style:{verticalCenter:0, left:0}},
			                             {rotate:false, resizeUp:false, resizeDown:false, resizeRight:true, resizeLeft:false,style:{verticalCenter:0, right:0}},
			                             {rotate:true,  resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:false,style:{verticalCenter:2, right:-4}}
										];	

			var imgHandleOptions:Array = [  {rotate:false, resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:false, style:{top:-0.5, horizontalCenter:0 }},
			                             {rotate:false, resizeUp:true, resizeDown:false, resizeRight:false, resizeLeft:true,style:{top:-0.5, left:-0.5}},
			                             {rotate:false, resizeUp:true, resizeDown:false, resizeRight:true, resizeLeft:false,style:{top:-0.5, right:-0.5}},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:false,style:{bottom:-0.5, horizontalCenter:0 }},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:false, resizeLeft:true,style:{bottom:-0.5, left:-0.5 }},
			                             {rotate:false, resizeUp:false, resizeDown:true, resizeRight:true, resizeLeft:false,style:{bottom:-0.5, right:-0.5}},
			                             {rotate:false, resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:true,style:{verticalCenter:0, left:-0.5}},
			                             {rotate:false, resizeUp:false, resizeDown:false, resizeRight:true, resizeLeft:false,style:{verticalCenter:0, right:-0.5}},
			                             {rotate:true,  resizeUp:false, resizeDown:false, resizeRight:false, resizeLeft:false,style:{verticalCenter:0.5, right:-1}}
										];	
			
			var handleOptions:Array = resizeHandleImage != null ? imgHandleOptions : defaultHandleOptions;
			
			for each (var option:Object in handleOptions)
			{
				
﻿				var isCorner:Boolean = 2 == (      ( option.resizeUp ? 1 : 0 ) +
								   ( option.resizeDown ? 1 : 0 ) +
								   ( option.resizeLeft ? 1 : 0 ) +
								   ( option.resizeRight ? 1 : 0 ) ); // Corners can resize in 2 directions.
				
				if( (! isCorner ) && (alwaysMaintainAspectRatio) )
				{					
					continue; // We don't show handles that you can't use.
				}
				
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
				
				
				var handle:Handle;
				
				if( option.rotate && (rotateHandleImage != null) )
				{
					handle = new ImageHandle( rotateHandleImage );
				}
				else if(  (resizeHandleImage != null) )
				{
					handle = new ImageHandle( resizeHandleImage );
				}
				else
				{				
					handle = new Handle();
				}
								
				handle.resizeDown = option.resizeDown;
				handle.resizeLeft = option.resizeLeft;
				handle.resizeRight = option.resizeRight;
				handle.resizeUp = option.resizeUp;
				handle.rotate = option.rotate;
				handle.visible = false;
				
								
				for (var prop:String in option.style)
				{
					switch(prop)
					{
						case "top":
						case "bottom":
		 					handle.setStyle(prop, option.style[prop] * handle.height );
		 					break;
		 				default:
		 					handle.setStyle(prop, option.style[prop] * handle.width );
		 					break;
	 				}	  	
	  			}
	  			
				super.addChild(handle);	
				handles.push(handle);		
			}										
			return handles;
		}		
		
		
		protected function applyConstraints(desiredPositon:Point, desiredSize:Point):void
		{
			var diff:int;
			
		//	var
			
			var effectiveMinHeight:Number = minHeight;
			var effectiveMinWidth:Number =  minWidth;
/*
	I can't rememember why I put this Math.max in there... the maxHorizontalPosition was big
	in a project I had and was causing problems so I've removed it for now.
				
			var effectiveMinHeight:Number = Math.max( minHeight, maxVerticalScrollPosition );
			var effectiveMinWidth:Number = Math.max( minWidth, maxHorizontalScrollPosition );
*/			
			// Minimum height check
			if( desiredSize.y < effectiveMinHeight  )
			{
				diff = effectiveMinHeight - desiredSize.y;
				desiredSize.y = effectiveMinHeight;
				
				if( desiredPositon.y != y )
				{
					desiredPositon.y -= diff;
				}
				
			}
			
			// Minimum width check
			if( desiredSize.x < effectiveMinWidth)
			{
				diff = effectiveMinWidth - desiredSize.x;
				desiredSize.x = effectiveMinWidth;
				
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