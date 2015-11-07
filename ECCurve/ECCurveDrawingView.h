//
//  BezierLineDrawingView.h
//  ECCurve
//
//  Created by Eric on 29/10/2015.
//  Copyright © 2015 Eric Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECCurveClippingImageModel.h"

#define kPointMinDistance 5
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface ECCurveDrawingView : UIView {
 
    UIBezierPath *mainPath;
    
    //For restore previous valid path after user draws a very short path
    UIBezierPath *previousMainPath;
    
    UIColor *brushPattern;
    
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    
    NSMutableArray *drawnPoints;
        
    CGSize finalSizeOfPathScaling;
    CGSize beginningSizeOfPathScaling;
    
    ECCurveClippingImageModel *clippingImageModel;
    
    UIImageView *scissorImageView;
    CGAffineTransform originalTransformInScissorImageView;
    
    NSNumber *angleBetweenPreviousAndCurrentPointForScissor;
    NSValue *centerOfScissor;
    
    UIView *sameSizeWithCurrentView;
    
    //for debug
    CAShapeLayer *dotCollection;
}

@property (nonatomic, readonly) UIBezierPath *mainPath;
@property (nonatomic, retain) NSNumber *angleBetweenPreviousAndCurrentPointForScissor;
@property (nonatomic, retain) NSValue *centerOfScissor;

- (id)initWithFrame:(CGRect)frame andPath: (id) receivedPath andCurrentImageSize: (CGSize) aCurrentImageViewImageSize andAngle: (NSNumber*) anAngleBetweenPreviousAndCurrentPointForScissor andScissorCenter: (NSValue*) aCenterOfScissor;
-(void) revertToNoPath;

-(void) processingTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) processingTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) processingTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) processingTouchesBeganWithFingerPoint: (CGPoint) fingerPoint;
-(void) processingTouchesMovedWithFingerPoint: (CGPoint) fingerPoint;
-(void) processingTouchesEnded;



@end
