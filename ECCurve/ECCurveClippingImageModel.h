//
//  ClippingImageModel.h
//  ECCurve
//
//  Created by Eric on 29/10/2015.
//  Copyright © 2015 Eric Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECCurveClippingImageModel : NSObject {  
}

- (UIBezierPath *)shrinkOrEnlargePath:(UIBezierPath *)path finalAreaSize:(CGSize) aFinalAreaSize beginningAreaSize:(CGSize) aBeginningAreaSize;
-(CGPoint) makePoint: (CGPoint) aPoint insideBoundary: (CGRect) aBoundary;
-(CGPoint) makePoint: (CGPoint) aPoint insideBackgroundCropBoundary: (CGRect) aBoundary;

@end
