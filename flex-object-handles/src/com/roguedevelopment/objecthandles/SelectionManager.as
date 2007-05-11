package com.roguedevelopment.objecthandles
{
	public class SelectionManager
	{
		private static var _instance:SelectionManager;
		private var _items:Array = new Array();
		public var currentlySelected:Selectable = null;
		
		public static function  get instance() : SelectionManager
		{
			if( ! _instance ) { _instance = new SelectionManager(); }
			return _instance;
		}
		
		public function selectNone() : void
		{
			setSelected(null);
		}
		
		public function setSelected(obj:Selectable) : void
		{
			if( obj == currentlySelected ) { return; }
			
			currentlySelected = obj;
			
			for each (var s:Selectable in _items)
			{
				if( s == obj )
				{
					s.select();
				}
				else
				{
					s.deselect();					
				}
			}
		}
		public function addSelectable(obj:Selectable) : void
		{
			_items.push(obj);
		}
	}
}