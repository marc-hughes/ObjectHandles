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
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.containers.Canvas;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.effects.Rotate;
	import mx.events.FlexEvent;

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
        [Embed(source="resizeHandle.png")]
        public var resizeHandleImage:Class ;
        
        /**
        * An embedded image to use for the rotate handles.
        * If you leave this null it will be programatically drawn.
        **/
        [Inspectable]
        [Embed(source="rotateHandle.png")]
        public var rotateHandleImage:Class ;

        
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
		
		protected var _allowKeyboardManipulation:Boolean = true;
		public function set allowKeyboardManipulation(val:Boolean) : void { _allowKeyboardManipulation = val; setupKeyboardListeners(); }
		public function get allowKeyboardManipulation() : Boolean { return _allowKeyboardManipulation ; }
		
		protected var rotateEffect:Rotate;
		
		public function ObjectHandles()
		{
			super();
			focusEnabled = true;
			
			creationPolicy = "all";
			mouseChildren = false;
			mouseEnabled = true;
			buttonMode = false;
			addEventListener( FlexEvent.CREATION_COMPLETE, init );
			addEventListener( Event.ADDED_TO_STAGE, addedToStage );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStage );						
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;			
			clipContent = false;
		}
		
		protected function addedToStage(e:Event) : void
		{
			SelectionManager.instance.addSelectable( this );
		}
		
		protected function removedFromStage(e:Event) : void
		{
			SelectionManager.instance.removeSelectable(this);
		}

		
		protected function init(event:FlexEvent) : void
		{
			
//			if (clipContent) {
//				clipContent = resizeHandleImage == null;			
//			}			
						
			
			handles = createHandles();
			
			rotateEffect = new Rotate();
						
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, onMouseUp );		
			
			addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );			
			addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			
			
			addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			
			SelectionManager.instance.addSelectable(this);
			
			setupKeyboardListeners();
		}
		
		protected function setupKeyboardListeners() : void
		{
			if( _allowKeyboardManipulation )
			{
				addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
				addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocus );
			}
			else
			{
				removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
				removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocus );
			}
		}
		
		protected function onKeyFocus(event:FocusEvent) : void
		{
			
			if( parent is ObjectHandlesCanvas )
			{
				var ohc:ObjectHandlesCanvas = parent as ObjectHandlesCanvas;
				if( event.shiftKey )
				{
					if( ohc.retreatFocus(this) )
					{
						event.preventDefault();
					}
				}
				else
				{
					if( ohc.advanceFocus(this) )
					{
						event.preventDefault();
					}
				}
				
			}
			
			
		}
		
		protected function onKeyDown(event:KeyboardEvent ) : void
		{
			switch( event.keyCode )
			{
				case Keyboard.UP:   handleUpPress(event.shiftKey); break;
				case Keyboard.DOWN: handleDownPress(event.shiftKey); break;
				case Keyboard.LEFT: handleLeftPress(event.shiftKey); break;
				case Keyboard.RIGHT:handleRightPress(event.shiftKey); break;
				//case Keyboard.TAB:  handleTabPress(event); break;
				case Keyboard.SPACE:handleSpace(); break;
				
			}
		}
		
		protected function handleSpace() : void
		{
			SelectionManager.instance.setSelected( this );
		}
		
		protected function handleUpPress( shiftKeyDown:Boolean ) : void 
		{
			var size:Point = new Point(width,height);
			var pos:Point = new Point(x, y );
			
			if( shiftKeyDown )
			{
				size.y --;				
			}
			else
			{
				pos.y--;
			}
			applyConstraints( pos , size);
			y = pos.y;
			x = pos.x;
			width = size.x;
			height = size.y;
			dispatchMoved();
			dispatchResized();
		}
		protected function handleDownPress( shiftKeyDown:Boolean ) : void 
		{
			var size:Point = new Point(width,height);
			var pos:Point = new Point(x, y );
			
			if( shiftKeyDown )
			{
				size.y ++;				
			}
			else
			{
				pos.y++;
			}
			applyConstraints( pos , size);
			y = pos.y;
			x = pos.x;
			width = size.x;
			height = size.y;	
			dispatchMoved();
			dispatchResized();
				
		}
		protected function handleLeftPress( shiftKeyDown:Boolean ) : void 
		{
			var size:Point = new Point(width,height);
			var pos:Point = new Point(x, y );
			
			if( shiftKeyDown )
			{
				size.x --;				
			}
			else
			{
				pos.x --;
			}
			applyConstraints( pos , size);
			y = pos.y;
			x = pos.x;
			width = size.x;
			height = size.y;		
			dispatchMoved();
			dispatchResized();
				
		}
		protected function handleRightPress( shiftKeyDown:Boolean ) : void 
		{
			var size:Point = new Point(width,height);
			var pos:Point = new Point(x, y );
			
			if( shiftKeyDown )
			{
				size.x ++;				
			}
			else
			{
				pos.x++;
			}
			applyConstraints( pos , size);
			y = pos.y;
			x = pos.x;
			width = size.x;
			height = size.y;	
			dispatchMoved();
			dispatchResized();
					
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
			
			setFocus();
			
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
			
			/* removed by greg: &&  rotation = 0 */
			if( isResizingLeft && !isResizingUp && event.buttonDown)
			{	
				/*desiredPos.x = dest.x - localClickPoint.x;
				desiredSize.x = originalSize.x + (originalPosition.x - desiredPos.x);
				wasResized = true;
				wasResizedLeft = true;
				wasMoved = true;*/
				
				
				//trace("original matrix", this.transform.matrix);

			    // Create a translation matrice we will use it to find the
			    // new coordinates of A (topleft) point.

			    var translate_matrixL:Matrix = new Matrix();
			    // get the North cursor current Y position
			    // We use getRotatedRectPoint to get the rotated cooridates of the North
			    // handle at position width / 2

			    var rL:Number = this.rotation * (Math.PI/180);
			    var handleInitPosL:Point = getRotatedRectPoint(rL, new Point(0,this.height/2));
			    handleInitPosL.x += this.x
			    handleInitPosL.y += this.y      

			    // get the new North handle position
			    var handleNewPosL:Point = new Point();
			    handleNewPosL.x = handleInitPosL.x + globalToLocal( new Point(event.stageX, event.stageY)).x;

			    // diff betwee both X positions
			    var handlePosXDeltaL:Number = handleNewPosL.x - handleInitPosL.x;

			    // No we translate by the difference on X 
			    translate_matrixL.translate(handlePosXDeltaL, 0);
			    // and dont forget to aply the current component transformation
			    // thanks to http://www.senocular.com/flash/tutorials/transformmatrix/
			    translate_matrixL.concat(this.transform.matrix);

			    // The new A position
			    var translated_pointL:Point = translate_matrixL.transformPoint(new Point(0, 0));
			    desiredPos.x =  translated_pointL.x;
			    desiredPos.y =  translated_pointL.y;

			    //trace("old height " ,this.height);

			    // new size since we move A and resize widht at the same time
			    desiredSize.x = this.width - handlePosXDeltaL;

			    // Guardian
			    // trace("new height ", desiredSize.y);
			    if (desiredSize.x < 0) {
			        wasMoved = false;
			        wasResized = false;
			    }
			    else {
			        wasMoved = true;
			        wasResized = true;
			    }
				
			}
			/* removed by greg: &&  rotation = 0 */
			if( isResizingUp && !isResizingLeft && event.buttonDown)
			{	
				//trace("original matrix", this.transform.matrix);

			    // Create a translation matrice we will use it to find the
			    // new coordinates of A (topleft) point.

			    var translate_matrixU:Matrix = new Matrix();
			    // get the North cursor current Y position
			    // We use getRotatedRectPoint to get the rotated cooridates of the North
			    // handle at position width / 2

			    var rU:Number = this.rotation * (Math.PI/180);
			    var handleInitPosU:Point = getRotatedRectPoint(rU, new Point(this.width/2,0));
			    handleInitPosU.x += this.x
			    handleInitPosU.y += this.y      

			    // get the new North handle position
			    var handleNewPosU:Point = new Point();
			    handleNewPosU.y = handleInitPosU.y + globalToLocal( new Point(event.stageX, event.stageY)).y;

			    // diff betwee both Y positions
			    var handlePosYDeltaU:Number = handleNewPosU.y - handleInitPosU.y;

			    // No we translate by the difference on Y 
			    translate_matrixU.translate(0, handlePosYDeltaU);
			    // and dont forget to aply the current component transformation
			    // thanks to http://www.senocular.com/flash/tutorials/transformmatrix/
			    translate_matrixU.concat(this.transform.matrix);

			    // The new A position
			    var translated_pointU:Point = translate_matrixU.transformPoint(new Point(0, 0));
			    desiredPos.x =  translated_pointU.x;
			    desiredPos.y =  translated_pointU.y;

			    //trace("old height " ,this.height);

			    // new size since we move A and resize widht at the same time
			    desiredSize.y = this.height - handlePosYDeltaU;

			    // Guardian
			    // trace("new height ", desiredSize.y);
			    if (desiredSize.y < 0) {
			        wasMoved = false;
			        wasResized = false;
			    }
			    else {
			        wasMoved = true;
			        wasResized = true;
			    }
			}
			if( isResizingUp && isResizingLeft && event.buttonDown)
			{	
				trace("original matrix", this.transform.matrix);

			    // Create a translation matrice we will use it to find the
			    // new coordinates of A (topleft) point.

			    var translate_matrix:Matrix = new Matrix();

			    var r:Number = this.rotation * (Math.PI/180);
			    var handleInitPos:Point = getRotatedRectPoint(r, new Point(0,0));
			    handleInitPos.x += this.x
			    handleInitPos.y += this.y      

			    // get the new North handle position
			    var handleNewPos:Point = new Point();
			    handleNewPos.y = handleInitPos.y + globalToLocal( new Point(event.stageX, event.stageY)).y;
			    handleNewPos.x = handleInitPos.x + globalToLocal( new Point(event.stageX, event.stageY)).x;

			    // diff betwee both Y positions
			    var handlePosYDelta:Number = handleNewPos.y - handleInitPos.y;
			    var handlePosXDelta:Number = handleNewPos.x - handleInitPos.x;
				
			//	trace("y delta " + handlePosYDelta )
			//	trace("x delta " + handlePosXDelta )
								
			    // No we translate by the difference on Y and X
			    translate_matrix.translate(handlePosXDelta, handlePosYDelta);
			
			    // and dont forget to aply the current component transformation
			    // thanks to http://www.senocular.com/flash/tutorials/transformmatrix/
			    translate_matrix.concat(this.transform.matrix);

			    // The new A position
			    var translated_point:Point = translate_matrix.transformPoint(new Point(0, 0));
			    desiredPos.x =  translated_point.x;
			    desiredPos.y =  translated_point.y;

			  //  trace("old height " ,this.height);
			//	trace("old width " ,this.width);

			    // new size since we move A and resize widht at the same time
			    desiredSize.y = this.height - handlePosYDelta;
				desiredSize.x = this.width - handlePosXDelta;

			    // Guardian
			 //   trace("new height ", desiredSize.y);
			//	trace("new width ", desiredSize.x);
			    if (desiredSize.y < 0 || desiredSize.x < 0) {
			        wasMoved = false;
			        wasResized = false;
			    }
			    else {
			        wasMoved = true;
			        wasResized = true;
			    }
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
				callLater( resizeMove, [desiredPos, desiredSize] );
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
			
			
			if( wasMoved ) {    dispatchMoving() ; }
			if( wasResized ) {  dispatchResizing() ; }
			if( wasRotated ) {  dispatchRotating(); }
			
			event.updateAfterEvent();
			
		}

		protected function resizeMove( desiredPos:Point, desiredSize:Point) : void
		{			
			width = desiredSize.x;
			height = desiredSize.y;			
			x = desiredPos.x;
			y = desiredPos.y
			validateNow();	
			
			trace(x + " " + width + " " + (x+width)) ;
		}
		
		override public function set width(value:Number):void
		{
			trace("W" + value);
			super.width = value;			
		}
		
		override public function set x(value:Number):void
		{
			trace("X" + value);
			super.x = value;
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
			drawFocus(false);
			showHandles(false);
			dispatchEvent( new ObjectHandleEvent(ObjectHandleEvent.OBJECT_DESELECTED) );		
		}
		
		protected function getMouseAngle():Number{
			return Math.atan2(parent.mouseY - y, parent.mouseX - x) * 180/Math.PI; 
		}
		
		public function setKeyboardFocus() : void
		{
			drawFocus(true);
			setFocus();
		}
				
		/* added by greg */
		// return the rotated point coordinates
		// help from http://board.flashkit.com/board/showthread.php?t=775357
		
		public function getRotatedRectPoint( angle:Number, point:Point, rotationPoint:Point = null):Point {
				    var ix:Number = (rotationPoint) ? rotationPoint.x : 0;
				    var iy:Number = (rotationPoint) ? rotationPoint.y : 0;
				    
				    var m:Matrix = new Matrix( 1,0,0,1, point.x - ix, point.y - iy);
				    
				    m.rotate(angle);
				    return new Point( m.tx + ix, m.ty + iy);
				}
		 /* end added */



	}
	

	
}
