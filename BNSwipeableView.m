//
//  BNSwipeableView.m
//  Banyan
//
//  Created by Devang Mundhra on 3/19/13.
//
//The MIT License (MIT)
//
//Copyright (c) 2013 Devang Mundhra
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "BNSwipeableView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BNSwipeableViewFrontView
- (void)drawRect:(CGRect)rect {
    
    if ([((BNSwipeableView *)self.superview).delegate respondsToSelector:@selector(drawFrontView:)])
        [((BNSwipeableView *)self.superview).delegate drawFrontView:rect];
}
@end

@implementation BNSwipeableViewBackView
- (void)drawRect:(CGRect)rect {
    if ([((BNSwipeableView *)self.superview).delegate respondsToSelector:@selector(drawBackView:)])
        [((BNSwipeableView *)self.superview).delegate drawBackView:rect];
}

@end

@interface BNSwipeableView()
@property (nonatomic) CGFloat startingXPositionAtSwipe;

@end

@interface BNSwipeableView (Private)
- (void)initialSetup;
- (void)resetViews:(BOOL)animated;
@end

@implementation BNSwipeableView
@synthesize backView;
@synthesize frontView;
@synthesize frontViewMoving;
@synthesize delegate;
@synthesize startingXPositionAtSwipe;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	if ((self = [super initWithCoder:aDecoder])){
		[self initialSetup];
	}
	
	return self;
}

- (void)initialSetup
{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    CGRect newBounds = self.bounds;
        
	frontView = [[BNSwipeableViewFrontView alloc] initWithFrame:newBounds];
	[frontView setClipsToBounds:YES];
	[frontView setOpaque:YES];
	[frontView setBackgroundColor:[UIColor clearColor]];
	
    UIPanGestureRecognizer *frontPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleFrontViewPan:)];
    frontPanRecognizer.delegate = self;
    [frontView addGestureRecognizer:frontPanRecognizer];
	
	backView = [[BNSwipeableViewBackView alloc] initWithFrame:newBounds];
	[backView setOpaque:YES];
	[backView setClipsToBounds:YES];
	[backView setHidden:YES];
	[backView setBackgroundColor:[UIColor redColor]];
	
    UISwipeGestureRecognizer * backSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleBackViewSwipe:)];
    // The direction of backview swipe depends on how it was revealed
	[backSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
	[backView addGestureRecognizer:backSwipeRecognizer];
    
	[self addSubview:backView];
	[self addSubview:frontView];
    
	frontViewMoving = NO;
    startingXPositionAtSwipe = 0.0f;
}

- (void)prepareForReuse {
	
	[self resetViews:NO];
}

- (void)setFrame:(CGRect)aFrame
{	
	[super setFrame:aFrame];
	
	CGRect newBounds = self.bounds;
	[backView setFrame:newBounds];
	[frontView setFrame:newBounds];
}

- (void)setNeedsDisplay {
	
	[super setNeedsDisplay];
	if (!frontView.hidden) [frontView setNeedsDisplay];
	if (!backView.hidden) [backView setNeedsDisplay];
}

//===============================//

#pragma mark - Back View Show / Hide
#define FRONTVIEW_HIDDEN_PORTION_ON_COMPLETION 0.92
- (void) toggleBackViewDisplay:(BOOL)animated
{
    if (backView.hidden) {
        [self revealBackViewAnimated:animated];
    } else {
        [self hideBackViewAnimated:animated];
    }
}

- (void)revealBackViewAnimated:(BOOL)animated
{
	if (!frontViewMoving && backView.hidden) {
        [self _prepareToRevealBackView:animated];
		        
		if (animated) {
            [self _completeFrontViewPan];
		}
		else {
            frontView.frame = CGRectOffset(frontView.bounds, -CGRectGetWidth(frontView.bounds)*FRONTVIEW_HIDDEN_PORTION_ON_COMPLETION, 0);
            
			frontViewMoving = NO;
            startingXPositionAtSwipe = 0;
            
            if ([delegate respondsToSelector:@selector(backViewDidAppear:)])
                [delegate backViewDidAppear:animated];
		}
	}
}

- (void)hideBackViewAnimated:(BOOL)animated
{
	
	if (!frontViewMoving && !backView.hidden){
		
		frontViewMoving = YES;
		
        if ([delegate respondsToSelector:@selector(backViewWillDisappear:)])
            [delegate backViewWillDisappear:animated];
		
		if (animated) {
            [self _resetFrontView];
		}
		else
		{
			[self resetViews:NO];
		}
	}
}

- (void)resetViews:(BOOL)animated {
	
    frontView.frame = CGRectOffset(frontView.bounds, 0, 0);
	frontViewMoving = NO;
	startingXPositionAtSwipe = 0;
	backView.hidden = YES;
    
    if ([delegate respondsToSelector:@selector(backViewDidDisappear:)])
        [delegate backViewDidDisappear:animated];
}

#pragma mark - Gesture recognizer delegate

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // We only want to deal with the gesture of it's a pan gesture
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [self.delegate shouldSwipe]) {
        CGPoint vel = [gestureRecognizer velocityInView:gestureRecognizer.view];
        BOOL rightToLeftSwipe = vel.x < 0;
        if (rightToLeftSwipe && !backView.hidden)
            return NO;
        if (!rightToLeftSwipe && backView.hidden)
            return NO;
        
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [panGestureRecognizer translationInView:[self superview]];
        return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
    } else {
        return NO;
    }
}

- (void)_handleFrontViewPan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    CGPoint actualTranslation = [panGestureRecognizer translationInView:panGestureRecognizer.view.superview];
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self _prepareToRevealBackView:YES];
        [self animateContentViewForPoint:actualTranslation velocity:velocity];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [self animateContentViewForPoint:actualTranslation velocity:velocity];
	} else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat deltaX =  actualTranslation.x;
        if (deltaX < -(CGRectGetWidth(self.bounds))*0.4) {
            [self _completeFrontViewPan];
        } else {
            [self _resetFrontView];
        }
	} else if (panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        [self _resetFrontView];
    }
}

- (void)_prepareToRevealBackView:(BOOL)animated
{
    frontViewMoving = YES;
    backView.hidden = NO;
    startingXPositionAtSwipe = CGRectGetMinX(frontView.frame);
    [backView setNeedsDisplay];
    
    if ([delegate respondsToSelector:@selector(backViewWillAppear:)])
        [delegate backViewWillAppear:animated];
}

- (void)_handleBackViewSwipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    [self hideBackViewAnimated:YES];
}

#pragma mark - Gesture animations

-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    frontView.frame = CGRectOffset(frontView.bounds, point.x+startingXPositionAtSwipe, 0);
}

- (void)_completeFrontViewPan
{
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         frontView.frame = CGRectOffset(frontView.bounds, -CGRectGetWidth(frontView.bounds)*FRONTVIEW_HIDDEN_PORTION_ON_COMPLETION, 0);
                     }
                     completion:^(BOOL finished) {
                         if ([delegate respondsToSelector:@selector(backViewDidAppear:)])
                             [delegate backViewDidAppear:YES];
                         
                         frontViewMoving = NO;
                         startingXPositionAtSwipe = 0;
                     }
     ];
}

-(void)_resetFrontView
{
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         frontView.frame = CGRectOffset(frontView.bounds, 0, 0);
                     }
                     completion:^(BOOL finished) {
                         [self resetViews:YES];
                     }
     ];
}

#pragma mark - Other
- (NSString *)description {
	
	NSString * extraInfo = backView.hidden ? @"FrontView visible": @"BackView visible";
	return [NSString stringWithFormat:@"<BNSwipeableView %p; '%@'>", self, extraInfo];
}

@end
