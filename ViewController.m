//
//  CanvasViewController.m
//  ECCurve
//
//  Created by Eric on 29/10/2015.
//  Copyright © 2015 Eric Cheung. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    touchStarted = NO;
    
    float screenMargin = 20;
    
    CGRect drawingArea = CGRectMake(screenMargin, screenMargin, [[UIScreen mainScreen] bounds].size.width - screenMargin*2, [[UIScreen mainScreen] bounds].size.height - screenMargin*2);

    
    
    
    
    NSNumber *angleBetweenPreviousAndCurrentPointForScissor = @(-5);
    
    CGPoint scissorCenter = CGPointMake(200, 150);
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath addArcWithCenter:CGPointMake(200, 200) radius:50 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    
    
    
    
    ecCurveDrawingView = [[ECCurveDrawingView alloc] initWithFrame:drawingArea
                                                              andPath: aPath
                                                  andCurrentImageSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width - screenMargin*2, [[UIScreen mainScreen] bounds].size.height - screenMargin*2)
                                                             andAngle:angleBetweenPreviousAndCurrentPointForScissor
                                                     andScissorCenter: [NSValue valueWithCGPoint:scissorCenter]];
    
    
    
    
    //Note: use   andPath: [NSNull null]   so a path will not appear at the beginning
//    ecCurveDrawingView = [[ECCurveDrawingView alloc] initWithFrame:drawingArea
//                                                                 andPath: [NSNull null]
//                                                     andCurrentImageSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width - screenMargin*2, [[UIScreen mainScreen] bounds].size.height - screenMargin*2)
//                                                                andAngle:angleBetweenPreviousAndCurrentPointForScissor
//                                                        andScissorCenter: [NSValue valueWithCGPoint:scissorCenter]];
    
    
    
    
    ecCurveDrawingView.backgroundColor = [UIColor colorWithRed:255/255.0 green:252/255.0 blue:200/255.0 alpha:1.0];
    
    [self.view addSubview:ecCurveDrawingView];
    
    //Detecting the drag of a finger; moving a picture
    panRecognizerMove = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [panRecognizerMove setMinimumNumberOfTouches:1];
    [panRecognizerMove setMaximumNumberOfTouches:1];
    [panRecognizerMove setDelegate:self];
    [self.view addGestureRecognizer:panRecognizerMove];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Ref: http://www.cocoachina.com/ask/questions/show/87463/%E5%90%84%E7%A7%8D%E6%89%8B%E5%8A%BF%E7%BB%84%E5%90%88%E9%97%AE%E9%A2%98
-(void)panned:(UIPanGestureRecognizer*)gesture{
    
    //When a user begin drawing outside the image boudary, the red dotted line will shown at the image boundary
        CGPoint currentFingerPoint = [gesture locationInView:ecCurveDrawingView];
        
        if (gesture.state == UIGestureRecognizerStateBegan) {    DLog();
            
                touchStarted = YES;
                [ecCurveDrawingView processingTouchesBeganWithFingerPoint:currentFingerPoint];

        }
        
        if (gesture.state == UIGestureRecognizerStateChanged) {    DLog();
            
            if (touchStarted) {
                [ecCurveDrawingView processingTouchesMovedWithFingerPoint:currentFingerPoint];
            }
        }
        
        if (gesture.state == UIGestureRecognizerStateEnded) {    DLog();
            
            if (touchStarted) {
                [ecCurveDrawingView processingTouchesEnded];
                touchStarted = NO;
            }
        }
    
}


@end
