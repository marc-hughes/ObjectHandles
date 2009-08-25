/**
 *  Latest information on this project can be found at http://www.rogue-development.com/objectHandles.html
 * 
 *  Copyright (c) 2009 Marc Hughes 
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
 *    
 *    Alexander Kludt
 *    Thomas Jakobi
 *    Mario Ernst
 *    Aaron Winkler
 *    Gregory Tappero
 *    Andrew Westberg
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
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;
    
    import mx.containers.Canvas;
    import mx.core.ClassFactory;
    import mx.core.Container;
    import mx.core.IFactory;
    import mx.events.PropertyChangeEvent;
    import mx.events.ScrollEvent;

    [Event(name="objectMoved",type="com.roguedevelopment.objecthandles.ObjectChangedEvent")]
    [Event(name="objectResized",type="com.roguedevelopment.objecthandles.ObjectChangedEvent")]
    [Event(name="objectRotated",type="com.roguedevelopment.objecthandles.ObjectChangedEvent")]
    public class ObjectHandles extends EventDispatcher
    {
        protected const zero:Point = new Point(0,0);
        
        protected var container:Sprite;
        public var selectionManager:ObjectHandlesSelectionManager;
        protected var handleFactory:IFactory;
        
        public var defaultHandles:Array = [];
        
        // Key = a Model, value = an Array of handles
        protected var handles:Dictionary = new Dictionary(); 
        
        // Key = a visual, value = the model
        protected var models:Dictionary = new Dictionary(); 

        // Key = a model, value = the visual
        protected var visuals:Dictionary = new Dictionary();
        
        // Key = a model, value = an array of HandleDescription objects;
        protected var handleDefinitions:Dictionary = new Dictionary(); 
        
        // Array of unused, visible=false handles
        protected var handleCache:Array = [];
        
        protected var temp:Point = new Point(0,0);
        
        protected var isDragging:Boolean = false;
        protected var currentDragRole:uint = 0;
        protected var mouseDownPoint:Point;
        protected var mouseDownRotation:Number;
        protected var originalGeometry:DragGeometry;
        
        public var constraints:Array = [];
        
        public var currentHandleConstraint:IFactory;
        
       //used to remember object changes so
       //events can be fired when the changes are complete
       private var isMoved:Boolean = false;
       private var isResized:Boolean = false;
       private var isRotated:Boolean = false;
            
        public function ObjectHandles(  container:Sprite , 
                                        selectionManager:ObjectHandlesSelectionManager = null, 
                                        handleFactory:IFactory = null)
        {       
            this.container = container;
            
            //container.addEventListener(MouseEvent.ROLL_OUT, onContainerRollOut );
            container.addEventListener( ScrollEvent.SCROLL, onContainerScroll );
            
            
            if( selectionManager )          
                this.selectionManager = selectionManager;           
            else            
                this.selectionManager = new ObjectHandlesSelectionManager();
            
            
            if( handleFactory )
                this.handleFactory = handleFactory;
            else
                this.handleFactory = new ClassFactory( Handle );
            
            
            this.selectionManager.addEventListener(SelectionEvent.ADDED_TO_SELECTION, onSelectionAdded );
            this.selectionManager.addEventListener(SelectionEvent.REMOVED_FROM_SELECTION, onSelectionRemoved );
            this.selectionManager.addEventListener(SelectionEvent.SELECTION_CLEARED, onSelectionCleared );
            
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_LEFT, 
                                                        zero ,
                                                        zero ) ); 
        
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_UP ,
                                                        new Point(50,0) , 
                                                        zero ) ); 
        
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_RIGHT,
                                                        new Point(100,0) ,
                                                        zero ) ); 
        
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_RIGHT,
                                                        new Point(100,50) , 
                                                        zero ) ); 
        
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_RIGHT,
                                                        new Point(100,100) , 
                                                        zero ) ); 
            
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_DOWN ,
                                                        new Point(50,100) ,
                                                        zero ) ); 
            
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_LEFT,
                                                        new Point(0,100) ,
                                                        zero ) ); 
        
            defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_LEFT,
                                                        new Point(0,50) ,
                                                        zero ) ); 
        
//          defaultHandles.push( new HandleDescription( HandleRoles.MOVE,
//                                                      new Point(50,50) , 
//                                                      zero ) ); 
        
            defaultHandles.push( new HandleDescription( HandleRoles.ROTATE,
                                                        new Point(100,50) , 
                                                        new Point(20,0) ) ); 
            
        }
        
        public function registerComponent( dataModel:Object, visualDisplay:EventDispatcher , handleDescriptions:Array = null, captureKeyEvents:Boolean = true) : void
        {
            visualDisplay.addEventListener( MouseEvent.MOUSE_DOWN, onComponentMouseDown, false, 0, true );
            visualDisplay.addEventListener( SelectionEvent.SELECTED, handleSelection );
            if(captureKeyEvents)
            {
             visualDisplay.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
            }
            dataModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
            models[visualDisplay] = dataModel;
            visuals[dataModel] = visualDisplay;     
            if( handleDescriptions )
            {
                handleDefinitions[ dataModel ] = handleDescriptions;
            }               
        }
        
        protected function onKeyDown(event:KeyboardEvent):void
        {
            var t:DragGeometry = new DragGeometry();
            switch(event.keyCode )
            {
                case Keyboard.UP : t.y --; break;
                case Keyboard.DOWN : t.y ++; break;
                case Keyboard.RIGHT : t.x ++; break;
                case Keyboard.LEFT : t.x --; break;             
                default:return; 
            }
            
            applyConstraints( t, HandleRoles.MOVE );
            applyTranslation( t );
        }
        
        /**
         * Returns true if the given model should have a movement handle.
         **/
        protected function hasMovementHandle( model:Object ) : Boolean
        {
            var desiredHandles:Array = getHandleDefinitions(model);
            for each ( var handle:HandleDescription in desiredHandles )
            {
                if( HandleRoles.isMove( handle.role ) ) return true;
            }
            return false;
        }
        
        public function unregisterComponent( visualDisplay:EventDispatcher ) : void
        {
            visualDisplay.removeEventListener( MouseEvent.MOUSE_DOWN, onComponentMouseDown);
            visualDisplay.removeEventListener( SelectionEvent.SELECTED, handleSelection );
            visualDisplay.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
            var dataModel:Object = findModel(visualDisplay as DisplayObject);
            dataModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
            
            delete visuals[dataModel];
            delete models[visualDisplay];
        }
        
        protected function onModelChange(event:PropertyChangeEvent):void
        {
            switch( event.property )
            {
                case "x":
                case "y":
                case "width":
                case "height":
                case "rotation": updateHandlePositions(event.target);
            }
        }
        
        protected function onSelectionAdded( event:SelectionEvent ) : void
        {
            for each ( var model:Object in event.targets )
            {
                setupHandles( model );
            }
        }
        
        protected function onSelectionRemoved( event:SelectionEvent ) : void
        {
            for each ( var model:Object in event.targets )
            {
                removeHandles( model );
            }
            
        }
        
        protected function onSelectionCleared( event:SelectionEvent ) : void
        {
            for each ( var model:Object in event.targets )
            {
                removeHandles( model );
            }

        }
        
        protected function onComponentMouseDown(event:MouseEvent):void
        {           
            handleSelection( event );
            
            container.stage.addEventListener(MouseEvent.MOUSE_MOVE, onContainerMouseMove );
            container.stage.addEventListener( MouseEvent.MOUSE_UP, onContainerMouseUp );

            try
            {
              event.target.setFocus();
            }catch(e:Error){}
            
            var model:Object = findModel( event.target as DisplayObject);
            if( ! hasMovementHandle(model) )
            {
                currentDragRole = HandleRoles.MOVE; // a mouse down on the component itself as opposed to a handle is a move operation.
                currentHandleConstraint = null;
                handleBeginDrag( event );
            }
        }
        
        protected function onContainerRollOut(event:MouseEvent) : void
        {
            isDragging = false; 
        }
        
        
        protected function onContainerMouseUp( event:MouseEvent ) : void
        {
           if (isMoved)
           {
                dispatchEvent(new ObjectChangedEvent(selectionManager.currentlySelected, ObjectChangedEvent.OBJECT_MOVED, true));
           }
           else if (isResized)
           {
                dispatchEvent(new ObjectChangedEvent(selectionManager.currentlySelected, ObjectChangedEvent.OBJECT_RESIZED, true));
           }
           else if (isRotated)
           {
                dispatchEvent(new ObjectChangedEvent(selectionManager.currentlySelected, ObjectChangedEvent.OBJECT_ROTATED, true));
           }
           
           isMoved = false;
           isResized = false;
           isRotated = false;
           container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onContainerMouseMove );
           container.stage.removeEventListener( MouseEvent.MOUSE_UP, onContainerMouseUp );
        
           isDragging = false;
        }
               
    
        protected function onContainerScroll(event:ScrollEvent):void
        {
            for each (var model:Object in models )
            {
                updateHandlePositions(model);
            }
        }
        protected function onContainerMouseMove( event:MouseEvent ) : void
        {
            if( ! isDragging ) { return; }
            var translation:DragGeometry = new DragGeometry();
            
            if( HandleRoles.isMove( currentDragRole ) )
            {
                isMoved = true;
                applyMovement( event, translation );
                applyConstraints(translation, currentDragRole );
            }
            
            if( HandleRoles.isResizeLeft( currentDragRole ) )
            {
                isResized = true;
                applyResizeLeft( event, translation );              
            }
            
            if( HandleRoles.isResizeUp( currentDragRole) )
            {
                isResized = true;
                applyResizeUp( event, translation );                
            }
            
            if( HandleRoles.isResizeRight( currentDragRole ) )
            {
                isResized = true;
                applyResizeRight( event, translation );             
            }

            if( HandleRoles.isResizeDown( currentDragRole ) )
            {
                isResized = true;
                applyResizeDown( event, translation );                      
            }
            
            if( HandleRoles.isRotate( currentDragRole ) )
            {
                isRotated = true;
                applyRotate( event, translation );              
            }
            
            applyTranslation( translation );            
            
            event.updateAfterEvent();               
        }
        
        protected function applyTranslation( translation:DragGeometry) : void
        {
            if( selectionManager.currentlySelected.length == 1 )
            {               
                var current:Object = selectionManager.currentlySelected[0];
                
                if( current.hasOwnProperty("x") ) current.x = translation.x + originalGeometry.x;
                if( current.hasOwnProperty("y") ) current.y = translation.y + originalGeometry.y;
                if( current.hasOwnProperty("width") ) current.width = translation.width + originalGeometry.width;
                if( current.hasOwnProperty("height") ) current.height = translation.height + originalGeometry.height;
                if( current.hasOwnProperty("rotation") ) current.rotation = translation.rotation + originalGeometry.rotation;
                
                updateHandlePositions(  current );
                    
            }
            else if( selectionManager.currentlySelected.length > 1 )
            {
                // todo: handle multiple selects
            }

        }
        
        protected function applyConstraints(translation:DragGeometry, currentDragRole:uint):void
        {
            if (currentHandleConstraint != null)
            {
                currentHandleConstraint.newInstance().applyConstraint( originalGeometry, translation, currentDragRole );
            }
            for each ( var constraint:IConstraint in constraints )
            {
                constraint.applyConstraint( originalGeometry, translation, currentDragRole );
            }
        }
        protected function applyRotate( event:MouseEvent, proposed:DragGeometry ) : void
        {
            var centerRotatedAmount:Number = toRadians(originalGeometry.rotation) - toRadians(mouseDownRotation) + getAngleInRadians(event.stageX, event.stageY);
            
            var oldRotationMatrix:Matrix = new Matrix();
            oldRotationMatrix.rotate( toRadians( originalGeometry.rotation) );
            var oldCenter:Point = oldRotationMatrix.transformPoint(new Point(originalGeometry.width/2,originalGeometry.height/2));
//          
            var newRotationMatrix:Matrix = new Matrix();
            //newRotationMatrix.rotate( toRadians(originalGeometry.rotation) );
            newRotationMatrix.translate(-oldCenter.x, -oldCenter.y);//-originalGeometry.width/2,-originalGeometry.height/2);                                    
            newRotationMatrix.rotate( centerRotatedAmount );
            newRotationMatrix.translate(oldCenter.x, oldCenter.y);                          
            var newOffset:Point = newRotationMatrix.transformPoint( zero );
            
            
            proposed.x += newOffset.x;
            proposed.y += newOffset.y;
            proposed.rotation = toDegrees(centerRotatedAmount);
        }    
        
        
 
        
         protected function getAngleInRadians(x:Number,y:Number):Number
         {
            var m:Matrix = new Matrix();
            var mousePos:Point = container.globalToLocal( new Point(x,y) );
            var angle1:Number;
            m.rotate( toRadians( originalGeometry.rotation)  );
            var originalCenter:Point = m.transformPoint( new Point(originalGeometry.width/2, originalGeometry.height/2) );
            originalCenter.offset( originalGeometry.x,  originalGeometry.y );
            if( container is Canvas) {
                var parentCanvas:Canvas = container as Canvas;
                return Math.atan2((mousePos.y + parentCanvas.verticalScrollPosition) - originalCenter.y, (mousePos.x + parentCanvas.horizontalScrollPosition) - originalCenter.x) ; 
            }
            else 
                return Math.atan2(mousePos.y - originalCenter.x, mousePos.x - originalCenter.y) ; 
        }
        protected function applyMovement( event:MouseEvent, translation:DragGeometry ) : void
        {           
            temp.x = event.stageX;
            temp.y = event.stageY;
            var localDown:Point = container.globalToLocal( mouseDownPoint );
            var current:Point = container.globalToLocal( temp );
            var mouseDelta:Point = new Point( current.x - localDown.x, current.y - localDown.y );
            
            
            translation.x = mouseDelta.x;
            translation.y = mouseDelta.y;
            
        }
        
        protected function applyResizeRight( event:MouseEvent, translation:DragGeometry ) : void
        {
            var containerOriginalMousePoint:Point = container.globalToLocal(new Point( mouseDownPoint.x, mouseDownPoint.y ));       
            var containerMousePoint:Point = container.globalToLocal( new Point(event.stageX, event.stageY) );
            
            // "local coordinates" = the coordinate system that is relative to the piece that moves around.
            
            // matrix describes the current rotation and helps us to go from container to local coordinates 
            var matrix:Matrix = new Matrix();
            matrix.rotate( toRadians( originalGeometry.rotation ) );
            // The inverse matrix helps us to go from local to container coordinates
            var invMatrix:Matrix = matrix.clone();
            invMatrix.invert();
            
            // The point where we pressed the mouse down in local coordinates
            var localOriginalMousePoint:Point = invMatrix.transformPoint( containerOriginalMousePoint );
            // The point where the mouse is currently in local coordinates
            var localMousePoint:Point = invMatrix.transformPoint( containerMousePoint );
            
            // How far along the X axis (in local coordinates) has the mouse been moved?  This is the amount the user has tried to resize the object
            var resizeDistance:Number = localMousePoint.x - localOriginalMousePoint.x;
            
            // So our new width is the original width plus that resize amount
            translation.width +=  resizeDistance;
            
            applyConstraints(translation, currentDragRole );
            
            // Now, that we've resize the object, we need to know where the upper left corner should get moved to because when we resize left, we have to move left.
            var translationp:Point = matrix.transformPoint( zero );
            
            translation.x +=  translationp.x;
            translation.y +=  translationp.y;
        }
        
        protected function applyResizeDown( event:MouseEvent, translation:DragGeometry ) : void
        {
            var containerOriginalMousePoint:Point = container.globalToLocal(new Point( mouseDownPoint.x, mouseDownPoint.y ));       
            var containerMousePoint:Point = container.globalToLocal( new Point(event.stageX, event.stageY) );
            
            // "local coordinates" = the coordinate system that is relative to the piece that moves around.
            
            // matrix describes the current rotation and helps us to go from container to local coordinates 
            var matrix:Matrix = new Matrix();
            matrix.rotate( toRadians( originalGeometry.rotation ) );
            // The inverse matrix helps us to go from local to container coordinates
            var invMatrix:Matrix = matrix.clone();
            invMatrix.invert();
            
            // The point where we pressed the mouse down in local coordinates
            var localOriginalMousePoint:Point = invMatrix.transformPoint( containerOriginalMousePoint );
            // The point where the mouse is currently in local coordinates
            var localMousePoint:Point = invMatrix.transformPoint( containerMousePoint );
            
            // How far along the X axis (in local coordinates) has the mouse been moved?  This is the amount the user has tried to resize the object
            var resizeDistance:Number = localMousePoint.y - localOriginalMousePoint.y;
            
            // So our new width is the original width plus that resize amount
            translation.height +=  resizeDistance;
            
            applyConstraints(translation, currentDragRole );
            
            // Now, that we've resize the object, we need to know where the upper left corner should get moved to because when we resize left, we have to move left.
            var translationp:Point = matrix.transformPoint( zero );
            
            translation.x +=  translationp.x;
            translation.y +=  translationp.y;
        }
        
        protected function applyResizeLeft( event:MouseEvent, translation:DragGeometry ) : void
        {
            var containerOriginalMousePoint:Point = container.globalToLocal(new Point( mouseDownPoint.x, mouseDownPoint.y ));       
            var containerMousePoint:Point = container.globalToLocal( new Point(event.stageX, event.stageY) );
            
            // "local coordinates" = the coordinate system that is relative to the piece that moves around.
            
            // matrix describes the current rotation and helps us to go from container to local coordinates 
            var matrix:Matrix = new Matrix();
            matrix.rotate( toRadians( originalGeometry.rotation ) );
            // The inverse matrix helps us to go from local to container coordinates
            var invMatrix:Matrix = matrix.clone();
            invMatrix.invert();
            
            // The point where we pressed the mouse down in local coordinates
            var localOriginalMousePoint:Point = invMatrix.transformPoint( containerOriginalMousePoint );
            // The point where the mouse is currently in local coordinates
            var localMousePoint:Point = invMatrix.transformPoint( containerMousePoint );
            
            // How far along the X axis (in local coordinates) has the mouse been moved?  This is the amount the user has tried to resize the object
            var resizeDistance:Number = localOriginalMousePoint.x - localMousePoint.x ;
            
            // So our new width is the original width plus that resize amount
            translation.width +=  resizeDistance;
            
            
            applyConstraints(translation, currentDragRole );
            
            // Now, that we've resize the object, we need to know where the upper left corner should get moved to because when we resize left, we have to move left.
            var translationp:Point = matrix.transformPoint( new Point(-translation.width,0) );
            
            translation.x +=  translationp.x;
            translation.y +=  translationp.y;
        }
        
        protected function applyResizeUp( event:MouseEvent, translation:DragGeometry ) : void
        {
            var containerOriginalMousePoint:Point = container.globalToLocal(new Point( mouseDownPoint.x, mouseDownPoint.y ));       
            var containerMousePoint:Point = container.globalToLocal( new Point(event.stageX, event.stageY) );
            
            // "local coordinates" = the coordinate system that is relative to the piece that moves around.
            
            // matrix describes the current rotation and helps us to go from container to local coordinates 
            var matrix:Matrix = new Matrix();
            matrix.rotate( toRadians( originalGeometry.rotation ) );
            // The inverse matrix helps us to go from local to container coordinates
            var invMatrix:Matrix = matrix.clone();
            invMatrix.invert();
            
            // The point where we pressed the mouse down in local coordinates
            var localOriginalMousePoint:Point = invMatrix.transformPoint( containerOriginalMousePoint );
            // The point where the mouse is currently in local coordinates
            var localMousePoint:Point = invMatrix.transformPoint( containerMousePoint );
            
            // How far along the Y axis (in local coordinates) has the mouse been moved?  This is the amount the user has tried to resize the object
            var resizeDistance:Number = localOriginalMousePoint.y - localMousePoint.y ;
            
            // So our new width is the original width plus that resize amount
            translation.height +=  resizeDistance;
            
            applyConstraints(translation, currentDragRole );
            
            // Now, that we've resize the object, we need to know where the upper left corner should get moved to because when we resize left, we have to move left.
            var translationp:Point = matrix.transformPoint( new Point(0, -translation.height) );
            
            translation.x += translationp.x;
            translation.y += translationp.y;
        }       
        
        protected function findModel( display:DisplayObject ) : Object
        {
            var model:Object = models[ display ];
            
            
            while( (model==null) && (display.parent != null) )
            {
                display = display.parent as DisplayObject;
                model = models[ display ];
            }
            return model;
        }
        
        public function handleSelection( event : Event ) : void
        {
            var model:Object = findModel( event.target as DisplayObject );
            
            if( ! model ) { return; }
            selectionManager.setSelected( model );
            
            
        }

        protected function handleBeginDrag( event : MouseEvent ) : void
        {
            isDragging = true;  
            mouseDownPoint = new Point( event.stageX, event.stageY );           
            originalGeometry = selectionManager.getGeometry();
            mouseDownRotation = originalGeometry.rotation + toDegrees( getAngleInRadians(event.stageX, event.stageY) );         
        }
        
        protected function setupHandles( model:Object ) : void
        {   
            removeHandles(model);       
            
            var desiredHandles:Array = getHandleDefinitions(model);
            for each ( var descriptor:HandleDescription in desiredHandles )
            {
                createHandle( model, descriptor);
            }
            
            updateHandlePositions(model);
             
        }
        
        protected function getHandleDefinitions( model:Object ) :Array
        {
            var desiredHandles:Array;
            desiredHandles = handleDefinitions[ model ];
            if(! desiredHandles)
            {
                desiredHandles = defaultHandles;
            }
            return desiredHandles;
        }
        
        protected function createHandle( model:Object, descriptor:HandleDescription ) : void
        {
            var current:Array = handles[model];
            if( ! current ) 
            {
                current = [];
                handles[model] = current;
            }
            // todo: use cached handles for performance.
            var handle:IHandle
            
            if (descriptor.handleFactory != null)
            {
                handle = descriptor.handleFactory.newInstance() as IHandle;
            }
            else
            {
                handle = handleFactory.newInstance() as IHandle;
            }
            handle.targetModel = model;
            handle.handleDescriptor = descriptor;
            connectHandleEvents( handle , descriptor);
            current.push(handle);
            addToContainer( handle as Sprite);
            handle.redraw();
        }
        
        protected function getContainerScrollAmount() : Point
        {
            var rv:Point = new Point(0,0);
            
            if( container is Container )
            {
                var con:Container = container as Container;
                rv.x = con.horizontalScrollPosition;
                rv.y = con.verticalScrollPosition;
            }
            
            return rv;
        }
        
        protected function updateHandlePositions( model:Object ) : void
        {
            var h:Array = handles[model]
            var scroll:Point = getContainerScrollAmount();
            
            if( ! h ) { return; }
            for each ( var handle:IHandle in h )
            {                       
                if( model.hasOwnProperty("rotation") )
                {
                    var m:Matrix = new Matrix(  1, // first four form partial identity matrix
                                                0, 
                                                1, 
                                                0, 
                                                (model.width * handle.handleDescriptor.percentageOffset.x / 100)  + handle.handleDescriptor.offset.x, // The tX 
                                                (model.height * handle.handleDescriptor.percentageOffset.y / 100)  + handle.handleDescriptor.offset.y); // the tY 
                    m.rotate( toRadians( model.rotation ) );
                    var p:Point = m.transformPoint( zero );                                             
                    handle.x = p.x + model.x - Math.floor(handle.width / 2) - scroll.x;
                    handle.y = p.y + model.y - Math.floor(handle.height / 2) - scroll.y;
                }
                else
                {
                    handle.x =  model.x - Math.floor(handle.width / 2) + (model.width * handle.handleDescriptor.percentageOffset.x / 100)  + handle.handleDescriptor.offset.x - scroll.x;
                    handle.y =  model.y - Math.floor(handle.height / 2) + (model.height * handle.handleDescriptor.percentageOffset.y / 100)  + handle.handleDescriptor.offset.y - scroll.y;
                }
            }   
        }
        
        protected static function toRadians( degrees:Number ) :Number
        {
            return degrees * Math.PI / 180;
        }
        protected static function toDegrees( radians:Number ) :Number
        {
            return radians *  180 / Math.PI;
        }
        
        protected function connectHandleEvents( handle:IHandle , descriptor:HandleDescription) : void
        {
            handle.addEventListener( MouseEvent.MOUSE_DOWN, onHandleDown );
            
            
        }
        
        protected function onHandleDown( event:MouseEvent):void
        {
            var handle:IHandle = event.target as IHandle;
            if( ! handle ) { return; }
            
            
            container.stage.addEventListener(MouseEvent.MOUSE_MOVE, onContainerMouseMove );
            container.stage.addEventListener( MouseEvent.MOUSE_UP, onContainerMouseUp );

            currentDragRole = handle.handleDescriptor.role;
            currentHandleConstraint = handle.handleDescriptor.constraint;
            handleBeginDrag(event);
        }
        
        protected function addToContainer( display:Sprite):void
        {
            if( container is Canvas )
            {
                (container as Canvas).rawChildren.addChild(display);
            }
            else
            {
                container.addChild( display );
            }
        }       
        
        protected function removeFromContainer( display:Sprite):void
        {
            if( container is Canvas )
            {
                (container as Canvas).rawChildren.removeChild(display);
            }
            else
            {
                container.removeChild( display );
            }
        }
        

        protected function removeHandles( model:Object ) : void
        {
            var currentHandles:Array = handles[model];
            for each ( var handle:IHandle in currentHandles )
            {               
                if( handleCache.length <= 10 )
                {
                    handle.visible = false;
                    handleCache.push( handle );
                }
                else
                {
                    removeFromContainer( handle as Sprite);                  
                }
            }
            
            delete handles[model]; 
            
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