//
//  NPInfiniteScrollView.h
//  Red&White
//
//  Created by Nap1 on 02.02.15.
//  Copyright (c) 2015 div. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NPInfiniteScrollView : UIScrollView
// Redraws the subview placeholders.  If your subviews are redrawn after insertion (eg loading
// a UIImageView from the web), you should call this method to update their placeholders.
-(void) redrawPlaceHolders;
@end
