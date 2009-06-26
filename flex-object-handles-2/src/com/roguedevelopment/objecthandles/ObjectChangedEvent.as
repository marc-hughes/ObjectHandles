package com.roguedevelopment.objecthandles
{
   import flash.events.Event;

   public class ObjectChangedEvent extends Event
   {

       public static const OBJECT_MOVED:String = "objectMoved";
       public static const OBJECT_RESIZED:String = "objectResized";
       public static const OBJECT_ROTATED:String = "objectRotated";
       
       /**
       * An array of objects that were moved/resized or rotated.
       **/
       public var relatedObjects:Array;

       public function ObjectChangedEvent(relatedObjects:Array, type:String,bubbles:Boolean=false, cancelable:Boolean=false)
       {
           super(type, bubbles, cancelable);
           this.relatedObjects = relatedObjects;
       }

   }
}
