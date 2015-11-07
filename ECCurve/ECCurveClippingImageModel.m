//
//  ClippingImageModel.m
//  ECCurve
//
//  Created by Eric on 29/10/2015.
//  Copyright © 2015 Eric Cheung. All rights reserved.
//

#import "ECCurveClippingImageModel.h"

@implementation ECCurveClippingImageModel

- (UIBezierPath *)shrinkOrEnlargePath:(UIBezierPath *)aPath finalAreaSize:(CGSize) aFinalAreaSize beginningAreaSize:(CGSize) aBeginningAreaSize {
    
    DLog(@"aPath is %@", NSStringFromCGRect(aPath.bounds));
    
    float scaleFactorForWidth = aFinalAreaSize.width / aBeginningAreaSize.width;
    float scaleFactorForHeight = aFinalAreaSize.height / aBeginningAreaSize.height;
    DLog(@"aBeginningAreaSize.width is %f", aBeginningAreaSize.width);
    DLog(@" aFinalAreaSize.width is %f",  aFinalAreaSize.width);
    
    [aPath applyTransform:CGAffineTransformMakeScale(scaleFactorForWidth, scaleFactorForHeight)];
    DLog(@"aPath is %@", NSStringFromCGRect(aPath.bounds));
    return aPath;
    
}

//if the finger is outside the drawing area, the bezier path will still inside the drawing area (along on the boundary)
-(CGPoint) makePoint: (CGPoint) aPoint insideBoundary: (CGRect) aBoundary {
    if (!CGRectContainsPoint(aBoundary, aPoint)) { //finger point outside the image boundary
        if (aPoint.x < 0) {
            aPoint.x = 0;
        }
        
        if (aPoint.x > aBoundary.size.width) {
            aPoint.x = aBoundary.size.width;
        }
        
        if (aPoint.y < 0) {
            aPoint.y = 0;
        }
        
        if (aPoint.y > aBoundary.size.height) {
            aPoint.y = aBoundary.size.height;
        }
    }
    
    return aPoint;
}

//if the finger is outside the drawing area, the bezier path will still inside the drawing area (along on the boundary)
-(CGPoint) makePoint: (CGPoint) aPoint insideBackgroundCropBoundary: (CGRect) aBoundary {
    if (!CGRectContainsPoint(aBoundary, aPoint)) { //finger point outside the image boundary
        if (aPoint.x < aBoundary.origin.x) {
            aPoint.x = aBoundary.origin.x;
        }
        
        if (aPoint.x > aBoundary.size.width+ aBoundary.origin.x) {
            aPoint.x = aBoundary.size.width+ aBoundary.origin.x;
        }
        
        if (aPoint.y < aBoundary.origin.y) {
            aPoint.y = aBoundary.origin.y;
        }
        
        if (aPoint.y > aBoundary.size.height+ aBoundary.origin.y) {
            aPoint.y = aBoundary.size.height+ aBoundary.origin.y;
        }
    }
    
    return aPoint;
}

@end
