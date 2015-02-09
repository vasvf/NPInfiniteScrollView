//
//  NPInfiniteScrollView.m
//  Red&White
//
//  Created by Nap1 on 02.02.15.
//  Copyright (c) 2015 div. All rights reserved.
//

#import "NPInfiniteScrollView.h"

#define NPDebug 0

#if NPDebug
#define NPLog(...) NSLog(__VA_ARGS__)
#else 
#define NPLog(...)  //nothing
#endif

@interface NPInfiniteScrollView () <UIScrollViewDelegate>
@end

@implementation NPInfiniteScrollView {
    NSMutableArray *placeholderSubviews;
    
    BOOL hasHorizontalScroll;
    BOOL hasVerticalScroll;
    
    id <UIScrollViewDelegate> originalDelegate;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        placeholderSubviews = [NSMutableArray array];
    }
    return self;
}

-(void)setContentOffset:(CGPoint)contentOffset {
    //If size is not zero and we are dragging the scroll view
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero) && (!self.pagingEnabled || !self.decelerating)) {
        
        //if we scroll father than half of scroll size backwards with X coordinate
        if ((contentOffset.x<-self.frame.size.width/2) && hasHorizontalScroll) {
            NPLog(@"backwards %@, %@", NSStringFromCGPoint(contentOffset), NSStringFromCGSize(self.contentSize));
            contentOffset.x = ((int)contentOffset.x + (int)self.contentSize.width)%((int)self.contentSize.width);
        }
        
        //if we scroll father than half of scroll size forwards with X coordinate
        if ((contentOffset.x>self.contentSize.width-self.frame.size.width/2) && hasHorizontalScroll) {
            NPLog(@"forwards %@, %@", NSStringFromCGPoint(contentOffset), NSStringFromCGSize(self.contentSize));
            contentOffset.x = ((int)contentOffset.x - (int)self.contentSize.width)%((int)self.contentSize.width);
        }
        
        //if we scroll father than half of scroll size backwards with Y coordinate
        if ((contentOffset.y<-self.frame.size.height/2) && hasVerticalScroll) {
            NPLog(@"upwards %@, %@", NSStringFromCGPoint(contentOffset), NSStringFromCGSize(self.contentSize));
            contentOffset.y = ((int)contentOffset.y + (int)self.contentSize.height)%((int)self.contentSize.height);
        }
        
        //if we scroll father than half of scroll size forwards with Y coordinate
        if ((contentOffset.y>self.contentSize.height-self.frame.size.height/2) && hasVerticalScroll) {
            NPLog(@"downwards %@, %@", NSStringFromCGPoint(contentOffset), NSStringFromCGSize(self.contentSize));
            contentOffset.y = ((int)contentOffset.y - (int)self.contentSize.height)%((int)self.contentSize.height);
        }
    }
    [super setContentOffset:contentOffset];
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    
    hasHorizontalScroll = self.contentSize.width>self.frame.size.width;
    hasVerticalScroll = self.contentSize.height>self.frame.size.height;
    
    //Make insets the same size as content size (needed for paging disabled mode)
    [self setContentInset:UIEdgeInsetsMake(contentSize.height*2*hasVerticalScroll,
                                           contentSize.width*2*hasHorizontalScroll,
                                           contentSize.height*2*hasVerticalScroll,
                                           contentSize.width*2*hasHorizontalScroll)];
    
    //Redraw placeholders
    [self redrawPlaceHolders];
}

-(void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    [self redrawPlaceHolders];
}

-(void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    originalDelegate = delegate;
    [super setDelegate:self];
}

#pragma mark - Internal methods

-(void) redrawPlaceHolders {
    for (UIView *view in placeholderSubviews) {
        [view removeFromSuperview];
    }
    [placeholderSubviews removeAllObjects];
    
    CGRect leftRect = CGRectMake(0,
                                 0,
                                 self.frame.size.width,
                                 self.contentSize.height);
    
    CGRect rightRect = CGRectMake(self.contentSize.width-self.frame.size.width,
                                  0,
                                  self.frame.size.width,
                                  self.contentSize.height);
    
    CGRect topRect = CGRectMake(0,
                                0,
                                self.contentSize.width,
                                self.frame.size.height);
    
    CGRect bottomRect = CGRectMake(0,
                                   self.contentSize.height-self.frame.size.height,
                                   self.contentSize.width,
                                   self.frame.size.height);
    
    CGRect topLeftRect = CGRectMake(0,
                                    0,
                                    self.frame.size.width,
                                    self.frame.size.height);
    
    CGRect topRightRect = CGRectMake(self.contentSize.width-self.frame.size.width,
                                     0,
                                     self.frame.size.width,
                                     self.frame.size.height);
    
    CGRect bottomLeftRect = CGRectMake(0,
                                       self.contentSize.height-self.frame.size.height,
                                       self.frame.size.width,
                                       self.frame.size.height);
    
    CGRect bottomRightRect = CGRectMake(self.contentSize.width-self.frame.size.width,
                                        self.contentSize.height-self.frame.size.height,
                                        self.frame.size.width,
                                        self.frame.size.height);
    
    for (UIView *view in self.subviews) {
        // If view is in the first page of scroll view
        if (CGRectIntersectsRect(leftRect, view.frame) && hasHorizontalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          self.contentSize.width,
                                          0);
            [placeholderSubviews addObject:viewCopy];
        }
        
        // If view is in the last page of scroll view
        if (CGRectIntersectsRect(rightRect, view.frame) && hasHorizontalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          -self.contentSize.width,
                                          0);
            [placeholderSubviews addObject:viewCopy];
        }
        
        // If view is in the first page of scroll view
        if (CGRectIntersectsRect(topRect, view.frame) && hasVerticalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          0,
                                          self.contentSize.height);
            [placeholderSubviews addObject:viewCopy];
        }
        
        // If view is in the last page of scroll view
        if (CGRectIntersectsRect(bottomRect, view.frame) && hasVerticalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          0,
                                          -self.contentSize.height);
            [placeholderSubviews addObject:viewCopy];
        }
        
        // If view is in the top left page of scroll view AND scroll view has bidirectional scroll
        if (CGRectIntersectsRect(topLeftRect, view.frame) && hasVerticalScroll && hasHorizontalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          self.contentSize.width,
                                          self.contentSize.height);
            [placeholderSubviews addObject:viewCopy];
        }
        
        // If view is in the top right page of scroll view AND scroll view has bidirectional scroll
        if (CGRectIntersectsRect(topRightRect, view.frame) && hasVerticalScroll && hasHorizontalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          -self.contentSize.width,
                                          self.contentSize.height);
            [placeholderSubviews addObject:viewCopy];
        }
        
        // If view is in the bottom left page of scroll view AND scroll view has bidirectional scroll
        if (CGRectIntersectsRect(bottomLeftRect, view.frame) && hasVerticalScroll && hasHorizontalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          self.contentSize.width,
                                          -self.contentSize.height);
            [placeholderSubviews addObject:viewCopy];
        }
        
        // If view is in the bottom right page of scroll view AND scroll view has bidirectional scroll
        if (CGRectIntersectsRect(bottomRightRect, view.frame) && hasVerticalScroll && hasHorizontalScroll) {
            UIView *viewCopy;
            viewCopy = [[UIImageView alloc] initWithFrame:view.frame];
            [(UIImageView*)viewCopy setImage:[self imageFromLayer:view.layer]];
            viewCopy.frame = CGRectOffset(viewCopy.frame,
                                          -self.contentSize.width,
                                          -self.contentSize.height);
            [placeholderSubviews addObject:viewCopy];
        }
        
        
    }
    
    for (UIView *view in placeholderSubviews) {
        //You can use it for debug to see the magic
//        view.alpha = 0.5;
        [super addSubview:view];
    }
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions([layer frame].size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

#pragma mark - UIScrollViewDelegate Forwarders

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [originalDelegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
        [originalDelegate scrollViewDidZoom:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [originalDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero)) {

        //If target offset is far left
        if (((*targetContentOffset).x<-self.frame.size.width/2)) {
            NPLog(@"decelerating backwards %@, %@", NSStringFromCGPoint((*targetContentOffset)), NSStringFromCGSize(self.contentSize));
            [super setContentOffset:CGPointMake(self.contentOffset.x+self.contentSize.width, self.contentOffset.y)];
        }
        
        //If target offset is far right
        if ((*targetContentOffset).x>self.contentSize.width-self.frame.size.width/2) {
            NPLog(@"decelerating forwards %@, %@", NSStringFromCGPoint((*targetContentOffset)), NSStringFromCGSize(self.contentSize));
            [super setContentOffset:CGPointMake(self.contentOffset.x-self.contentSize.width, self.contentOffset.y)];
        }
        
        //If target offset is far up
        if (((*targetContentOffset).y<-self.frame.size.height/2)) {
            NPLog(@"decelerating upwards %@, %@", NSStringFromCGPoint((*targetContentOffset)), NSStringFromCGSize(self.contentSize));
            [super setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y+self.contentSize.height)];
        }
        
        //If target offset is far bottom
        if (((*targetContentOffset).y>self.contentSize.height-self.frame.size.height/2)) {
            NPLog(@"decelerating backwards %@, %@", NSStringFromCGPoint((*targetContentOffset)), NSStringFromCGSize(self.contentSize));
            [super setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y-self.contentSize.height)];
        }
        
    }
    
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
        [originalDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [originalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [originalDelegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [originalDelegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
        [originalDelegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
        return [originalDelegate viewForZoomingInScrollView:scrollView];
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
        [originalDelegate scrollViewWillBeginZooming:scrollView withView:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
        [originalDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
        return [originalDelegate scrollViewShouldScrollToTop:scrollView];
    
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
        [originalDelegate scrollViewDidScrollToTop:scrollView];
}

@end
