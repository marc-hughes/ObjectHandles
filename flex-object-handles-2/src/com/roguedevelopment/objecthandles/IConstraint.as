package com.roguedevelopment.objecthandles
{
	import flash.geom.Rectangle;
	
	public interface IConstraint
	{
		function applyConstraint( original:DragGeometry, proposed:DragGeometry, resizeHandleRole:uint ) : void;		
	}
}