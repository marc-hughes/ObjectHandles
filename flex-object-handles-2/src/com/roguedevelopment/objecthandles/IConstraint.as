package com.roguedevelopment.objecthandles
{
	import flash.geom.Rectangle;
	
	public interface IConstraint
	{
		function applyConstraint( original:DragGeometry, translation:DragGeometry, resizeHandleRole:uint ) : void;		
	}
}