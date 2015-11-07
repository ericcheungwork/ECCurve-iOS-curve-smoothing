//
//  CanvasViewController.h
//  ECCurve
//
//  Created by Eric on 29/10/2015.
//  Copyright © 2015 Eric Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECCurveDrawingView.h"

@interface ViewController : UIViewController <UIGestureRecognizerDelegate> {

    BOOL touchStarted;
    ECCurveDrawingView *ecCurveDrawingView;
    UIPanGestureRecognizer *panRecognizerMove;
    
}



@end
