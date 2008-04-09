package com.roguedevelopment.objecthandles
{
       import flash.display.Bitmap;
       import flash.events.Event;
       
       import mx.controls.Image;

       public class ImageHandle extends Handle
       {

               public function ImageHandle(image:Class)
               {
                       super();

						var bm:Bitmap = new image();
						addChild(bm);
						
						width = bm.width;
						height = bm.height;
						bm.x = 0;
						bm.y = 0;
						
               
               }


               private function errorLoading(event:Event):void{
                       super.draw();
               }

               protected override function draw():void
               {
               	
               }

       }
}