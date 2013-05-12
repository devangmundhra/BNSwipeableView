//
//  BNSwipeableView.h
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

#import <UIKit/UIKit.h>

@interface BNSwipeableViewFrontView : UIView
@end

@interface BNSwipeableViewBackView : UIView
@end

@protocol BNSwipeableViewDelegate <NSObject>

- (BOOL)shouldSwipe;

@optional
- (void)drawFrontView:(CGRect)rect;
- (void)drawBackView:(CGRect)rect;

- (void)backViewWillAppear:(BOOL)animated;
- (void)backViewDidAppear:(BOOL)animated;
- (void)backViewWillDisappear:(BOOL)animated;
- (void)backViewDidDisappear:(BOOL)animated;

- (void)didSwipe;

@end

@interface BNSwipeableView : UIView <UIGestureRecognizerDelegate> {
	
	UIView * frontView;
	UIView * backView;
	
	BOOL contentViewMoving;
	BOOL shouldBounce;
}

@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) UIView * frontView;
@property (nonatomic, assign) BOOL frontViewMoving;
@property (nonatomic, assign) BOOL shouldBounce;
@property (nonatomic, strong) id<BNSwipeableViewDelegate> delegate;

- (void)revealBackViewAnimated:(BOOL)animated inDirection:(UISwipeGestureRecognizerDirection)direction;
- (void)hideBackViewAnimated:(BOOL)animated inDirection:(UISwipeGestureRecognizerDirection)direction;

- (void)prepareForReuse;

@end
