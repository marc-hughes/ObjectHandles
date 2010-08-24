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
 *  See README for more information.
 *
 **/


/**
 * A handle implementation based on Sprite, primarily for use in Flex 3.
 **/
package com.roguedevelopment.objecthandles
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class SpriteHandle extends Sprite implements IHandle
	{
		/**
		 * Some global settings for the handle representation. Set using class, not instance!!!
		 *
		 * Use to change the size of the handles.
		 * usage: SpriteHandle.handleSize=4;
		 **/
		public static var handleSize:Number = 10;

		/**
		 * Use to change the fill color of the handles.
		 * usage: SpriteHandle.handleColor=0xff0000;
		 **/
		public static var handleColor:int = 0xaaaaaa;

		/**
		 * Use to change the OVER fill color of the handles.
		 * usage: SpriteHandle.handleColorOver=0x0000ff;
		 **/
		public static var handleColorOver:int = 0xc5ffc0;

		/**
		 * Use to change the border of the handle.
		 * usage: SpriteHandle.borderWidth=2;
		 **/
		public static var borderWidth:Number = 1.0;

		/**
		 * Use to change the stroke/line/border color of the handles.
		 * usage: SpriteHandle.handleBorderColor=0xff00ff;
		 **/
		public static var handleBorderColor:int = 0x000000;

		/**
		 * Use to change the OVER stroke/line/border color of the handles.
		 * usage: SpriteHandle.handleBorderColorOver=0x00ff00;
		 **/
		public static var handleBorderColorOver:int = 0x3dff40;

		private var _descriptor:HandleDescription;
		private var _targetModel:Object;
		protected var isOver:Boolean = false;

		public function get handleDescriptor():HandleDescription
		{
			return _descriptor;
		}
		public function set handleDescriptor(value:HandleDescription):void
		{
			_descriptor = value;
		}
		public function get targetModel():Object
		{
			return _targetModel;
		}
		public function set targetModel(value:Object):void
		{
			_targetModel = value;
		}

		public function SpriteHandle()
		{
			super();
			addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			//redraw();
		}

		protected function onRollOut( event : MouseEvent ) : void
		{
			isOver = false;
			redraw();
		}
		protected function onRollOver( event:MouseEvent):void
		{
			isOver = true;
			redraw();
		}

		public function redraw() : void
		{
			graphics.clear();
			if( isOver )
			{
				graphics.lineStyle(borderWidth,handleBorderColorOver);
				graphics.beginFill(handleColorOver,1);
			}
			else
			{
				graphics.lineStyle(borderWidth,handleBorderColor);
				graphics.beginFill(handleColor,1);
			}

			graphics.drawRect(-handleSize/2,-handleSize/2,handleSize,handleSize);
			graphics.endFill();

		}

	}
}