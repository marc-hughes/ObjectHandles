package com.roguedevelopment.objecthandles.constraints
{
	import com.roguedevelopment.objecthandles.DragGeometry;
	import com.roguedevelopment.objecthandles.HandleRoles;
	import com.roguedevelopment.objecthandles.IConstraint;
	
	/**
	 * This isn't really done yet.  It doesn't handle rotated objects well
	 **/
	public class MovementConstraint implements IConstraint
	{
		public var minX:Number;
		public var minY:Number;
		public var maxX:Number;
		public var maxY:Number;

		public function applyConstraint( original:DragGeometry, translation:DragGeometry, resizeHandleRole:uint ) : void
		{
			if( ! isNaN( maxX ) )
			{
				if( (original.x + translation.x + original.width + translation.width) > maxX )
				{
					if( HandleRoles.isMove( resizeHandleRole ) )
					{
						translation.x = maxX - (original.x + original.width );
					}
					else
					{
						translation.width = maxX - (original.x + translation.x + original.width );
						
					}
				}
			}
				
			if( ! isNaN( maxY ) )
			{
				if( (original.y + translation.y + original.height + translation.height) > maxY )
				{
					if( HandleRoles.isMove( resizeHandleRole ) )
					{
						translation.y = maxY - (original.y + original.height );
					}
					else
					{
						translation.height = maxY - (original.y + translation.y + original.height );
						
					}
				}
			}

			if( ! isNaN( minX ) )
			{							
				if( (original.x + translation.x) < minX )
				{
					translation.x = minX - original.x;
				}
			}

			if( ! isNaN( minY ) )
			{				
				if( (original.y + translation.y ) < minY )
				{
					translation.y = minY - original.y;
				}
			}	
		}

	}
}