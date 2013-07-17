//
//  STransitonSelectorVc.h
//  Sliden
//
//  Created by Amit Priyadarshi on 09/06/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "WorkSpace.h"

@interface STransitonSelectorVc : SGrayViewController <iCarouselDataSource,iCarouselDelegate>

@property (retain, nonatomic) IBOutlet iCarousel *icarouselView;
@property (nonatomic, strong) WorkSpace* workSpace;
- (IBAction)homeButtonTap:(id)sender;
- (IBAction)applyWholePackTap:(id)sender;
- (IBAction)keepSlidenTap:(id)sender;
@end
