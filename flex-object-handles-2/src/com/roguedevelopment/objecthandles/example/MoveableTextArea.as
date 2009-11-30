package com.roguedevelopment.objecthandles.example
{
	import flash.events.Event;
	
	import mx.controls.TextArea;
	import mx.events.PropertyChangeEvent;
	
	/** 
	 * This is an example and not part of the core ObjectHandles library. 
	 **/
	
	public class MoveableTextArea extends TextArea
	{
		protected var _model:TextDataModel;
		
		public function MoveableTextArea()
		{
			super();
			addEventListener(Event.CHANGE, onTextInput );
		}
		
		public function set model( val:TextDataModel ) : void
		{
			if( _model ) _model.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange );
			_model = val;
			reposition();
			
			val.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange );
		}
		
		protected function onTextInput(event:Event ):void
		{
			if( _model ) { _model.text = text; }
		}
		protected function onPropertyChange(event:PropertyChangeEvent ) : void
		{
			reposition();
		}
		protected function reposition() : void
		{
			drawFocus(false);
			x = _model.x;
			y = _model.y;
			width = _model.width;
			height = _model.height;
			rotation = _model.rotation;
			text = _model.text;
		}
		
	}
}