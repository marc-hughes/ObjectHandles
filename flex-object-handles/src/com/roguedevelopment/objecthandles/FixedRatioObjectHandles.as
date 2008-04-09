



package com.roguedevelopment.objecthandles
{
  import com.roguedevelopment.objecthandles.ObjectHandles;
  import flash.events.MouseEvent;
  import flash.display.DisplayObject;
  import com.roguedevelopment.objecthandles.Handle;
  import mx.events.FlexEvent;
  import mx.managers.CursorManager;
  import com.roguedevelopment.objecthandles.ObjectHandlesMouseCursors2;
  
  public class FixedRatioObjectHandles extends ObjectHandles  {
    
    /**
       * The aspect ratio.
       */ 	
    private var aspectRatio:Number = 0;
    
    /**
     * Holds the state whether the mouse is down.
     */  
    private var isMouseDown:Boolean = false;
    
    /**
     * The x and y numbers of the corners (handles).
     */ 
    private var topLeftX:Number = 0;
    private var topLeftY:Number = 0;
    private var topRightX:Number = 0;
    private var topRightY:Number = 0;
    private var bottomLeftX:Number = 0;
    private var bottomLeftY:Number = 0;
    private var bottomRightX:Number = 0;
    private var bottomRightY:Number = 0;
    
    /**
     * The constructor.
     */ 
    public function FixedRatioObjectHandles() {
      super();
      
      addEventListener(FlexEvent.CREATION_COMPLETE, removeUnnecessaryHandles);
    }
    
    /**
     * Removes all unnecessary handles.
     */ 
    private function removeUnnecessaryHandles(event:FlexEvent):void 
    {
     
      
      for each (var handle:Handle in super.handles) {
        if (handle.resizeLeft && !handle.resizeUp && !handle.resizeRight && !handle.resizeDown) {
          // is left handle
          removeChild(handle);
        }
        if (handle.resizeUp && !handle.resizeRight && !handle.resizeDown && !handle.resizeLeft) {
          // is up handle
          removeChild(handle);
        }
        if (handle.resizeRight && !handle.resizeDown && !handle.resizeLeft && !handle.resizeUp) {
          // is right handle
          removeChild(handle);
        }
        if (handle.resizeDown && !handle.resizeLeft && !handle.resizeUp && !handle.resizeRight) {
          // is down handle
          removeChild(handle);
        }
      }
    }
    
    /**
     * Handles the mouse down event.
     */ 
    protected override function onMouseDown(event:MouseEvent):void {


        // save aspect ratio
        aspectRatio = height / width;  
        
        // Remember coordinates
        topLeftX = this.x;
        topLeftY = this.y;
        topRightX = this.x + this.width;
        topRightY = this.y;
        bottomLeftX = this.x;
        bottomLeftY = this.y + this.height;
        bottomRightX = this.x + this.width;
        bottomRightY = this.y + this.height;
      
      
      this.isMouseDown = true;
      super.onMouseDown(event);
    }
    
    /**
     * Handles the mouse up event.
     */ 
    protected override function onMouseUp(event:MouseEvent):void {
      this.isMouseDown = false;
      super.onMouseUp(event);
    }
    
    /**
     * Handles the mouse move event.
     */ 
    protected override function onMouseMove(event:MouseEvent):void {
      
      super.onMouseMove(event);

      if ( isMouseDown) {
        // fit height
        height = width * aspectRatio;
        
        // Prevents this box to be moved to a wrong place when trying to resize with handles others than the bottom right handle.
        if (isResizingDown && isResizingRight) {
          // is bottom right handle, everything all right width positioning.
        } 
        if (isResizingUp && isResizingRight) {
          // is top right handle.
          x = topLeftX;
          y = bottomLeftY - height;
        }
        if (isResizingDown && isResizingLeft) {
          // is bottom left handle.
          x = topRightX - width;
          y = topRightY; 
        }
        if (isResizingUp && isResizingLeft) {
          // is top left handle.
          x = bottomRightX - width;
          y = bottomRightY - height;
        }        
      }
    }
  }
}