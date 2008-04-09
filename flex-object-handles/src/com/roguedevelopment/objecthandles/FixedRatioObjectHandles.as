
// This functionality is now contained in the main ObjectHandles class, just enable either the alwaysMaintainAspectRatio or cornerMaintainAspectRatio properties


package com.roguedevelopment.objecthandles
{

  public class FixedRatioObjectHandles extends ObjectHandles  
  {  	  	
  	public function FixedRatioObjectHandles() 
  	{
	  	alwaysMaintainAspectRatio = true;
	  	super();
	}
  }

}