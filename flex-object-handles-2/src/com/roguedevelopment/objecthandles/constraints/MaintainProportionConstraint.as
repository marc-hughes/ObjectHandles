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
package com.roguedevelopment.objecthandles.constraints
{
    import com.roguedevelopment.objecthandles.DragGeometry;
    import com.roguedevelopment.objecthandles.HandleRoles;
    import com.roguedevelopment.objecthandles.IConstraint;

	
	/** 
	 * This is a constraint which causes the resized component to maintain a constant aspect ration.
	 * 
	 * NOTE / TODO: Currently, it doesn't work 100% correctly for rotated objects.   
	 **/

    public class MaintainProportionConstraint implements IConstraint
    {
        public function applyConstraint(original:DragGeometry, translation:DragGeometry, resizeHandleRole:uint):void
        {
            //This doesn't quite work properly for rotated objects, but I'll fix that when I get more time.
            
            var originalProportion:Number = original.width / original.height;
            
            if (resizeHandleRole == HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_RIGHT)
            {
                if (translation.height * originalProportion > translation.width)
                {
                    if (translation.height != 0)
                    {
                        translation.width = translation.height * originalProportion;
                    }
                }
                else
                {
                    if (translation.width != 0)
                    {
                        translation.height = translation.width / originalProportion;
                    }
                }
            }
            
            if (resizeHandleRole == HandleRoles.RESIZE_UP + HandleRoles.RESIZE_RIGHT)
            {
                if (translation.height * originalProportion > translation.width)
                {
                    if (translation.height != 0)
                    {
                        translation.width = translation.height * originalProportion;
                    }
                }
                else
                {
                    if (translation.width != 0)
                    {
                        translation.height = translation.width / originalProportion;
                        translation.y = -translation.height;
                    }
                }
            }
            
            if (resizeHandleRole == HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_LEFT)
            {
                if (translation.height * originalProportion > translation.width)
                {
                    if (translation.height != 0)
                    {
                        translation.width = translation.height * originalProportion;
                        translation.x = -translation.width;
                    }
                }
                else
                {
                    if (translation.width != 0)
                    {
                        translation.height = translation.width / originalProportion;
                    }
                }
            }
            
            if (resizeHandleRole == HandleRoles.RESIZE_UP + HandleRoles.RESIZE_LEFT)
            {
                if (translation.height * originalProportion > translation.width)
                {
                    if (translation.height != 0)
                    {
                        translation.width = translation.height * originalProportion;
                        //not sure why, but we only have to do this on one axis and it still works...
                        //weird...
                        translation.x = -translation.width;
                    }
                }
                else
                {
                    if (translation.width != 0)
                    {
                        translation.height = translation.width / originalProportion;
                    }
                }
            }
        }
        
    }
}