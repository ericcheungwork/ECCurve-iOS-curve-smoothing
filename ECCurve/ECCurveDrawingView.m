//
//  BezierLineDrawingView.m
//  ECCurve
//
//  Created by Eric on 29/10/2015.
//  Copyright © 2015 Eric Cheung. All rights reserved.
//

#import "ECCurveDrawingView.h"


@implementation ECCurveDrawingView

@synthesize mainPath;

- (id)initWithFrame:(CGRect)frame andPath: (id) receivedPath andCurrentImageSize: (CGSize) aCurrentImageViewImageSize andAngle: (NSNumber*) anAngleBetweenPreviousAndCurrentPointForScissor andScissorCenter: (NSValue*) aCenterOfScissor{
    self = [super initWithFrame:frame];
    
    DLog(@"frame is %@", NSStringFromCGRect(frame));
    
    if (self) {
        
        sameSizeWithCurrentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        DLog(@"sameSizeWithCurrentView.frame is %@", NSStringFromCGRect(sameSizeWithCurrentView.frame));
        
        //183810 Code
        finalSizeOfPathScaling = aCurrentImageViewImageSize;
        beginningSizeOfPathScaling = frame.size;
        
        DLog(@"finalSizeOfPathScaling is %@", NSStringFromCGSize(finalSizeOfPathScaling));
        DLog(@"beginningSizeOfPathScaling is %@", NSStringFromCGSize(beginningSizeOfPathScaling)); 
        
        clippingImageModel = [[ECCurveClippingImageModel alloc] init];
        
        self.backgroundColor=[UIColor clearColor];
        
        brushPattern = [UIColor darkGrayColor];
        
        if ([receivedPath isEqual: [NSNull null]]) {
            mainPath=[[UIBezierPath alloc]init];
            
            DLog(@"mainPath.empty %@", mainPath.empty ? @"Yes" : @"No");

        } else {
            mainPath=receivedPath;
            
            if (anAngleBetweenPreviousAndCurrentPointForScissor != nil && ![anAngleBetweenPreviousAndCurrentPointForScissor isEqual:[NSNull null]]) {
                //If the anAngleBetweenPreviousAndCurrentPointForScissor is not either 1) nil or 2) NSNull
                self.angleBetweenPreviousAndCurrentPointForScissor = anAngleBetweenPreviousAndCurrentPointForScissor;
                self.centerOfScissor = aCenterOfScissor;
                
                [self insertScissorImage];
            }
            
            DLog(@"angleBetweenPreviousAndCurrentPointForScissor is %@", self.angleBetweenPreviousAndCurrentPointForScissor);
            DLog(@"centerOfScissor is %@", self.centerOfScissor);
            
            scissorImageView.hidden = NO;
            DLog(@"mainPath.empty %@", mainPath.empty ? @"Yes" : @"No");
            
            DLog(@"mainPath is %@", NSStringFromCGRect(mainPath.bounds));
            DLog(@"aCurrentImageViewImageSize is %@", NSStringFromCGSize(aCurrentImageViewImageSize));
            
            //If the mainPath is origin zero and size equal to aCurrentImageViewImageSize
            if (mainPath.bounds.origin.x == 0 &&
                mainPath.bounds.origin.y == 0 &&
                (int)mainPath.bounds.size.width == (int)aCurrentImageViewImageSize.width &&
                (int)mainPath.bounds.size.height == (int)aCurrentImageViewImageSize.height ) {
                brushPattern=[UIColor clearColor];
            }
            
        }
        
        [self setUpMainPathProperties];
        
        //Deep copy is necessary here
        previousMainPath = [NSKeyedUnarchiver unarchiveObjectWithData:
                    [NSKeyedArchiver archivedDataWithRootObject:mainPath]];
        
        DLog(@"mainPath.empty %@", mainPath.empty ? @"Yes" : @"No");

        
    }
    return self;
}

-(void) setUpMainPathProperties {
    mainPath.lineCapStyle=kCGLineCapRound;
    mainPath.miterLimit=0;
    mainPath.lineWidth=5.0;
    
    //Making dotted line
    //Ref: http://club15cc.com/code-snippets/ios-2/stroke-an-ellipse-with-a-dashed-line-with-quartz-2d
    const float p[2] = {8, 8};
    [mainPath setLineDash:p count:2 phase:8];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [brushPattern setStroke];
    [mainPath stroke];
//    [mainPath strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];
}

//For touchesBegan & touchesMoved Ref: https://github.com/levinunnink/Smooth-Line-View
#pragma mark - Touch Methods
-(void) processingTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self processingTouchesBeganWithFingerPoint:[touch locationInView:self]];
}

-(void) processingTouchesBeganWithFingerPoint: (CGPoint) fingerPoint {
    
    DLog(@"fingerPoint is %@", NSStringFromCGPoint(fingerPoint));
    
    brushPattern = [UIColor darkGrayColor];
    
    //Clear previous path
    [mainPath removeAllPoints];
    scissorImageView.hidden = YES;
    
    //Clear debug points
    if (dotCollection != nil) {
        [dotCollection removeFromSuperlayer];
        dotCollection = nil;
    }
    dotCollection = [CAShapeLayer layer];
    [self.layer addSublayer:dotCollection];
    //Clear debug points
    
    
    currentPoint = [clippingImageModel makePoint:fingerPoint insideBoundary:sameSizeWithCurrentView.frame];
    
    previousPoint1 = currentPoint;
    previousPoint2 = currentPoint;
    
    [mainPath moveToPoint: CGPointMid(previousPoint1, previousPoint2)];
    DLog(@"CGPointMid(previousPoint1, previousPoint2) is %@", NSStringFromCGPoint(CGPointMid(previousPoint1, previousPoint2)));
    DLog(@"previousPoint2 is %@", NSStringFromCGPoint(previousPoint2));
    DLog(@"currentPoint is %@", NSStringFromCGPoint(currentPoint));
    
    // record touch points to use as input to our line smoothing algorithm
    drawnPoints = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:currentPoint]];
    
    [self processingTouchesMovedWithFingerPoint:fingerPoint];
}

static CGPoint CGPointMid(CGPoint a, CGPoint b) {
    return (CGPoint) {(a.x+b.x)/2.0, (a.y+b.y)/2.0};
}

-(void) processingTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self processingTouchesMovedWithFingerPoint: [touch locationInView:self]];
}

-(void) processingTouchesMovedWithFingerPoint: (CGPoint) fingerPoint {
    DLog(@"fingerPoint is %@", NSStringFromCGPoint(fingerPoint));
    previousPoint2 = previousPoint1;
    previousPoint1 = currentPoint;
    currentPoint = [clippingImageModel makePoint:fingerPoint insideBoundary:sameSizeWithCurrentView.frame];

    DLog(@"self.frame is %@ , currentPoint is %@", NSStringFromCGRect(self.frame), NSStringFromCGPoint(currentPoint));
    
    // record touch points to use as input to our line smoothing algorithm
    [drawnPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
    
    DLog(@"currentPoint is %@", NSStringFromCGPoint(currentPoint));
    
    //
    //
    //     Bezier spline technology
    //
    //
    //Another ref: http://www.codeproject.com/Articles/31859/Draw-a-Smooth-Curve-through-a-Set-of-2D-Points-wit
    [mainPath addLineToPoint: CGPointMid(previousPoint1, previousPoint2)];
    [mainPath addQuadCurveToPoint: CGPointMid(currentPoint, previousPoint1) controlPoint: previousPoint1];
    
    [self setNeedsDisplay];
}

-(void) processingTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {     DLog();
    
    [self processingTouchesEnded];
}

-(void) processingTouchesEnded {

    [self produceASmootherPath];
    
    DLog(@"mainPath.empty %@", mainPath.empty ? @"Yes" : @"No");
    
    //183810 Code
    //The clipped area can't be smallar than the lower limits of width/ height specified in PrefixHeader.h; search 183810 to undersand more
    //if the clipped area is smallar than the lower limits, revert the path and show the alert message.
//    if ([self isTheCurveTooSmall]) {
//        //clear the curve
//        [self revertToNoPath];
//        
//        //Show error alert
//        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"The clipping area is too small"
//                                                          message:@"Please draw a bigger one \nor enlarge the image on canvas"
//                                                         delegate:self
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        
//        [myAlert show];
//    }
}


#pragma mark - smooth the curve

- (void)insertScissorImage { DLog();
    //Insert scissor image
    if (scissorImageView == nil) {
        scissorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scissor.png"]];
        scissorImageView.frame = CGRectMake(scissorImageView.frame.origin.x, scissorImageView.frame.origin.y, scissorImageView.frame.size.width/5*3, scissorImageView.frame.size.height/5*3); //Reduce the size of scissorImageView
        originalTransformInScissorImageView = scissorImageView.transform;
        scissorImageView.hidden = YES;
        [self addSubview: scissorImageView];
        
    }
    scissorImageView.center = [self.centerOfScissor CGPointValue];
    
    CGAffineTransform newTransform = CGAffineTransformRotate(originalTransformInScissorImageView, DEGREES_TO_RADIANS([self.angleBetweenPreviousAndCurrentPointForScissor floatValue]-90.0) );
    [scissorImageView setTransform:newTransform];
    scissorImageView.hidden = NO;
}

-(void) produceASmootherPath {
    NSArray *generalizedPoints = [self douglasPeucker:drawnPoints epsilon:1.5];
    
    [mainPath removeAllPoints];
    
    CGPoint firstPoint;
    
    //draw a new smoother path only if [generalizedPoints count] >= 5
    if ([generalizedPoints count] >= 5) {

        for (int i = 0; i < [generalizedPoints count]; i++) {
            NSValue *aPoint = [generalizedPoints objectAtIndex:i];
            
            if (i != 0) {
                previousPoint2 = previousPoint1;
                previousPoint1 = currentPoint;
                currentPoint = [aPoint CGPointValue];
                
                [mainPath addLineToPoint: CGPointMid(previousPoint1, previousPoint2)];
                [mainPath addQuadCurveToPoint: CGPointMid(currentPoint, previousPoint1) controlPoint: previousPoint1];
                
                DLog(@"change in degree is %f", [self pointPairToBearingDegrees:currentPoint secondPoint:previousPoint1]);
                
                //Code 912631 - enable this line for debugging
//                [self printDotForDebugInCGPoint:currentPoint inColor:[UIColor magentaColor]];
                
            } else {
                firstPoint = [aPoint CGPointValue];
                
                previousPoint2 = [aPoint CGPointValue];
                previousPoint1 = [aPoint CGPointValue];
                currentPoint = [aPoint CGPointValue];
                
                [mainPath moveToPoint: CGPointMid(previousPoint1, previousPoint2)];
            }
            
        }
        
        DLog(@"currentPoint is %@", NSStringFromCGPoint(currentPoint));
        DLog(@"previousPoint2 is %@", NSStringFromCGPoint(previousPoint2));
        
        self.angleBetweenPreviousAndCurrentPointForScissor = [NSNumber numberWithFloat:[self pointPairToBearingDegrees:currentPoint secondPoint:previousPoint2]];
        
        DLog(@"angleBetweenPreviousAndCurrentPointForScissor is %@", self.angleBetweenPreviousAndCurrentPointForScissor);
        
        self.centerOfScissor = [NSValue valueWithCGPoint:currentPoint];
        
        [self insertScissorImage];

        DLog(@"mainPath is %@, previousMainPath is %@", mainPath, previousMainPath);
        
        //Deep copy is necessary
        previousMainPath = [NSKeyedUnarchiver unarchiveObjectWithData:
                            [NSKeyedArchiver archivedDataWithRootObject:mainPath]];
        
        DLog(@"mainPath is %@, previousMainPath is %@", mainPath, previousMainPath);
        
    } else {
        
        DLog(@"(line too short / too straight -  can't form a close path at this line of code) mainPath is %@, previousMainPath is %@", mainPath, previousMainPath);

        //Restore old path; deep copy is necessary
        mainPath = [NSKeyedUnarchiver unarchiveObjectWithData:
                                          [NSKeyedArchiver archivedDataWithRootObject:previousMainPath]];
        scissorImageView.hidden = NO;
        
        if (mainPath == nil) {
            DLog(@"mainPath is nil");
            DLog(@"mainPath.empty %@", mainPath.empty ? @"Yes" : @"No");
    
            [self revertToNoPath];
                        
            DLog(@"mainPath.empty %@", mainPath.empty ? @"Yes" : @"No");
        } else {
            DLog(@"mainPath is not nil");
        }
        
        DLog(@"mainPath is %@, previousMainPath is %@", mainPath, previousMainPath);
    }
    
    DLog();
    
    [self setNeedsDisplay];
}

//
//
//    Using Ramer–Douglas–Peucker algorithm to reduce the number of points (making the curve smoother)
//
//
//Ref: http://tonyngo.net/2011/09/smooth-line-drawing-in-ios/
//Ref 2: http://en.wikipedia.org/wiki/Ramer–Douglas–Peucker_algorithm
- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon {
    int count = [points count];
    if(count < 3) {
        return points;
    }
    
    //Find the point with the maximum distance
    float dmax = 0;
    int index = 0;
    for(int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self perpendicularDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    //If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) {
        NSArray *recResults1 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];
        
        NSArray *recResults2 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    } else {
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    }
    
    return resultList;
}

- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB {
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}

-(void) revertToNoPath {           DLog();
    mainPath = nil;
    mainPath = [[UIBezierPath alloc] init];
    scissorImageView.hidden = YES;
    
    [self setUpMainPathProperties];
    [self setNeedsDisplay];
    
    //Revert the previousMainPath also
    //Deep copy is necessary
    previousMainPath = [NSKeyedUnarchiver unarchiveObjectWithData:
                        [NSKeyedArchiver archivedDataWithRootObject:mainPath]];
    
    DLog(@"should be YES bezierLineDrawingView mainPath.empty %@", mainPath.empty ? @"Yes" : @"No");
}

//183810 Code
//Calculate the size of the path (size of mainPathHavingSameSizeAtCanvas below) to be showed in the canvas, return YES if the path is too small
//-(BOOL) isTheCurveTooSmall{
//    
//    if (!mainPath.empty) {
//        
//        //Deep copy is necessary for mainPath
//        UIBezierPath *mainPathHavingSameSizeAtCanvas = [clippingImageModel shrinkOrEnlargePath:[NSKeyedUnarchiver unarchiveObjectWithData:
//                                                                                     [NSKeyedArchiver archivedDataWithRootObject:mainPath]]
//                                                                      finalAreaSize:finalSizeOfPathScaling
//                                                                  beginningAreaSize:beginningSizeOfPathScaling];
//        
//        DLog(@"main path bounds is %@", NSStringFromCGRect(mainPath.bounds));
//        DLog(@"mainPathHavingSameSizeAtCanvas bounds is %@", NSStringFromCGRect(mainPathHavingSameSizeAtCanvas.bounds));
//        
//        //if the bezier path too small, return yes; no otherwise
//        if (mainPathHavingSameSizeAtCanvas.bounds.size.width >= imageWidthLowerLimit &&
//            mainPathHavingSameSizeAtCanvas.bounds.size.height >= imageHeightLowerLimit) {
//            //mainPathHavingSameSizeAtCanvas.bounds.size.height <= imageHeightUpperLimit
//            //mainPathHavingSameSizeAtCanvas.bounds.size.width <= imageWidthUpperLimit
//            return NO;
//        } else {
//            return YES;
//        }
//
//        
//    } else { //nothing happen if run this IF body part
//        return NO;
//    }
//}

//Finding a angle between 2 points
//Ref: http://stackoverflow.com/questions/6064630/get-angle-from-2-positions
- (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint {
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}

-(void) printDotForDebugInCGPoint: (CGPoint) aPoint inColor: (UIColor*) aColor {
    //Notice: search Code 912631 for when to use the function (now they are disabled)
    
    // Set up the shape of the circle
    int radius = 6;
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    
    circle.position = CGPointMake(aPoint.x-radius, aPoint.y-radius); //Origin of the circle
    
    // Configure the apperence of the circle
    circle.fillColor = aColor.CGColor;
    
    // Add to parent layer
    [dotCollection addSublayer:circle];
}



@end
