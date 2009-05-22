package com.roguedevelopment.objecthandles.constraints
{
	import com.roguedevelopment.objecthandles.DragGeometry;
	import com.roguedevelopment.objecthandles.IConstraint;
	
	public class SizeConstraint implements IConstraint
	{
		public var maxWidth:Number;
		public var minWidth:Number;
		public var maxHeight:Number;
		public var minHeight:Number;
		
		public function applyConstraint( original:DragGeometry, translation:DragGeometry, resizeHandleRole:uint ) : void		
		{
			if( ! isNaN( maxWidth ) )
			{
				if( (original.width + translation.width) > maxWidth )
				{
					translation.width = maxWidth - original.width;
				}
			}
				
			if( ! isNaN( maxHeight ) )
			{
				if( (original.height + translation.height) > maxHeight )
				{
					translation.height = maxHeight - original.height;
				}
			}

			if( ! isNaN( minWidth ) )
			{							
				if( (original.width + translation.width) < minWidth )
				{
					translation.width = minWidth - original.width;
				}
			}

			if( ! isNaN( minHeight ) )
			{				
				if( (original.height + translation.height) < minHeight )
				{
					translation.height = minHeight - original.height;
				}
			}	
								
			
		}

	}
}