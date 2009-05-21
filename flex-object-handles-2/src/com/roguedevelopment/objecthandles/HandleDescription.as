package com.roguedevelopment.objecthandles
{
	import flash.geom.Point;
	
	public class HandleDescription
	{		
		public var role:uint;
		public var percentageOffset:Point;
		public var offset:Point;
		
		
		public function HandleDescription(role:uint, percentageOffset:Point, offset:Point ) 
		{
			this.role = role;
			this.percentageOffset = percentageOffset;
			this.offset = offset;
		}
	}
}