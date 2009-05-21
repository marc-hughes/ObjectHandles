package com.roguedevelopment.objecthandles
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.containers.Canvas;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class ObjectHandles
	{
		protected var container:Sprite;
		protected var selectionManager:ObjectHandlesSelectionManager;
		protected var handleFactory:IFactory;
		
		protected var defaultHandles:Array = [];
		
		// Key = a Model, value = an Array of handles
		protected var handles:Dictionary = new Dictionary(); 
		
		// Key = a visual, value = the model
		protected var models:Dictionary = new Dictionary(); 

		// Key = a model, value = the visual
		protected var visuals:Dictionary = new Dictionary(); 
		
		// Array of unused, visible=false handles
		protected var handleCache:Array = [];
		
		protected var isDragging:Boolean = false;
		protected var currentDragRole:uint = 0;
		protected var mouseDownPoint:Point;
		protected var originalGeometry:DragGeometry;
		
		public var constraints:Array = [];
			
		public function ObjectHandles(  container:Sprite , 
										selectionManager:ObjectHandlesSelectionManager = null, 
										handleFactory:IFactory = null)
		{		
			this.container = container;
			container.addEventListener(MouseEvent.MOUSE_MOVE, onContainerMouseMove );
			container.addEventListener(MouseEvent.ROLL_OUT, onContainerRollOut );
			container.addEventListener( MouseEvent.MOUSE_UP, onContainerMouseUp );
			
			
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
														new Point(0,0) ,
														new Point(0,0) ) ); 
		
			defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_UP ,
														new Point(50,0) , 
														new Point(0,0) ) ); 
		
			defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_RIGHT,
														new Point(100,0) ,
														new Point(0,0) ) ); 
		
			defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_RIGHT,
														new Point(100,50) , 
														new Point(0,0) ) ); 
		
			defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_RIGHT,
														new Point(100,100) , 
														new Point(0,0) ) ); 
			
			defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_DOWN ,
														new Point(50,100) ,
														new Point(0,0) ) ); 
			
			defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_LEFT,
														new Point(0,100) ,
														new Point(0,0) ) ); 
		
			defaultHandles.push( new HandleDescription( HandleRoles.RESIZE_LEFT,
														new Point(0,50) ,
														new Point(0,0) ) ); 
		
			defaultHandles.push( new HandleDescription( HandleRoles.MOVE,
														new Point(50,50) , 
														new Point(0,0) ) ); 
		
			defaultHandles.push( new HandleDescription( HandleRoles.ROTATE,
														new Point(100,50) , 
														new Point(20,0) ) ); 
			
		}
		
		public function registerComponent( dataModel:Object, visualDisplay:EventDispatcher ) : void
		{
			visualDisplay.addEventListener( MouseEvent.MOUSE_DOWN, onComponentMouseDown, false, 0, true );
			models[visualDisplay] = dataModel;
			visuals[dataModel] = visualDisplay;						
		}
		
		public function unregisterComponent( visualDisplay:EventDispatcher ) : void
		{
			visualDisplay.removeEventListener( MouseEvent.MOUSE_DOWN, onComponentMouseDown);
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
			currentDragRole = HandleRoles.MOVE; // a mouse down on the component itself as opposed to a handle is a move operation.
			handleSelection( event );
			handleBeginDrag( event );
		}
		
		protected function onContainerRollOut(event:MouseEvent) : void
		{
			isDragging = false;	
		}
		
		protected function onContainerMouseUp( event:MouseEvent ) : void
		{
			isDragging = false;
		}
		
		protected function onContainerMouseMove( event:MouseEvent ) : void
		{
			if( ! isDragging ) { return; }
			var proposed:DragGeometry = originalGeometry.clone();
			
			if( HandleRoles.isMove( currentDragRole ) )
			{
				applyMovement( event, proposed );
			}
			
			if( HandleRoles.isResizeLeft( currentDragRole ) )
			{
				applyResizeLeft( event, proposed );
			}
			
			if( HandleRoles.isRotate( currentDragRole ) )
			{
				applyRotate( event, proposed );
			}
			
			
			for each ( var constraint:IConstraint in constraints )
			{
				constraint.applyConstraint( originalGeometry, proposed, currentDragRole );
			}						
			
			if( selectionManager.currentlySelected.length == 1 )
			{
				var current:Object = selectionManager.currentlySelected[0];
				
				if( current.hasOwnProperty("x") ) current.x = proposed.x;
				if( current.hasOwnProperty("y") ) current.y = proposed.y;
				if( current.hasOwnProperty("width") ) current.width = proposed.width;
				if( current.hasOwnProperty("height") ) current.height = proposed.height;
				if( current.hasOwnProperty("rotation") ) current.rotation = proposed.rotation;
				
				updateHandlePositions(  current );
				 	
			}
			else if( selectionManager.currentlySelected.length > 1 )
			{
				// todo: handle multiple selects
			}
			
			
			event.updateAfterEvent();				
		}
		
		protected function applyRotate( event:MouseEvent, proposed:DragGeometry ) : void
		{
             proposed.rotation = Math.round(localClickRotation - localClickAngle + getMouseAngle());       
  		}     
  		
  		 protected function getMouseAngle():Number
  		 {
          
            var angle1:Number;
            if( parent is Canvas) {
                var parentCanvas:Canvas = parent as Canvas;
                return Math.atan2((parent.mouseY + parentCanvas.verticalScrollPosition) - y, (parent.mouseX + parentCanvas.horizontalScrollPosition) - x) * 180/Math.PI; 
            }
            else 
                return Math.atan2(parent.mouseY - y, parent.mouseX - x) * 180/Math.PI; 
        }
		protected function applyMovement( event:MouseEvent, proposed:DragGeometry ) : void
		{
			var mouseDelta:Point = new Point( event.stageX - mouseDownPoint.x, event.stageY - mouseDownPoint.y );
			var currentMousePoint:Point = container.globalToLocal( new Point(event.stageX, event.stageY) );
			
			proposed.x = originalGeometry.x + mouseDelta.x;
			proposed.y = originalGeometry.y + mouseDelta.y;
			
		}
		
		protected function applyResizeLeft( event:MouseEvent, proposed:DragGeometry ) : void
		{
			var mouseDelta:Point = new Point( event.stageX - mouseDownPoint.x, event.stageY - mouseDownPoint.y );
			var currentMousePoint:Point = container.globalToLocal( new Point(event.stageX, event.stageY) );
			
			proposed.x = originalGeometry.x + mouseDelta.x;
			proposed.y = originalGeometry.y + mouseDelta.y;
			
		}
		
		protected function handleSelection( event : MouseEvent ) : void
		{
			var model:Object = models[ event.target ];
			if( ! model ) { return; }
			selectionManager.setSelected( model );
			
			
		}

		protected function handleBeginDrag( event : MouseEvent ) : void
		{
			isDragging = true;	
			mouseDownPoint = new Point( event.stageX, event.stageY );
			originalGeometry = selectionManager.getGeometry();			
		}
		
		protected function setupHandles( model:Object ) : void
		{	
			removeHandles(model);		
			var desiredHandles:Array;
			if( model is IHandleDescriber )
			{
				desiredHandles = (model as IHandleDescriber).getHandleDescriptors();
			}
			else
			{
				desiredHandles = defaultHandles;
			}
			
			for each ( var descriptor:HandleDescription in desiredHandles )
			{
				createHandle( model, descriptor);
			}
			
			updateHandlePositions(model);
			 
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
			var handle:Handle = handleFactory.newInstance() as Handle;
			handle.targetModel = model;
			handle.descriptor = descriptor;
			connectHandleEvents( handle , descriptor);
			current.push(handle);
			addToContainer( handle );						
		}
		
		protected function updateHandlePositions( model:Object ) : void
		{
			var h:Array = handles[model]
			if( ! h ) { return; }
			for each ( var handle:Handle in h )
			{
				handle.x = model.x + (model.width * handle.descriptor.percentageOffset.x / 100) - Math.floor(handle.width / 2) + handle.descriptor.offset.x;
				handle.y = model.y + (model.height * handle.descriptor.percentageOffset.y / 100) - Math.floor(handle.height / 2) + handle.descriptor.offset.y;
			}	
		}
		
		protected function connectHandleEvents( handle:Handle , descriptor:HandleDescription) : void
		{
			handle.addEventListener( MouseEvent.MOUSE_DOWN, onHandleDown );
			
			
		}
		
		protected function onHandleDown( event:MouseEvent):void
		{
			var handle:Handle = event.target as Handle;
			if( ! handle ) { return; }
			
			currentDragRole = handle.descriptor.role;
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
			for each ( var handle:Handle in currentHandles )
			{				
				if( handleCache.length <= 10 )
				{
					handle.visible = false;
					handleCache.push( handle );
				}
				else
				{
					removeFromContainer( handle );					
				}
			}
			
			delete handles[model]; 
			
		}
	}
}