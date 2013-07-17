//
//  SPhotoSelectorVc.h
//  Sliden
//
//  Created by Amit Priyadarshi on 21/06/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SViewController.h"
#import "ELCImagePickerController.h"
#import "WorkSpace.h"
#import "WorkingImage.h"
#import "DragbleThumb.h"

@interface SPhotoSelectorVc : SGrayViewController <ELCImagePickerControllerDelegate, DragbleThumbDelegate> {
    DragbleThumb* heldTile;
    int      heldFrameIndex;
    CGPoint  heldStartPosition;
    CGPoint  touchStartLocation;
    NSMutableArray* tileFrame;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (retain, nonatomic) IBOutlet UIButton *rearrangeButton;
@property (nonatomic, strong) WorkSpace* workSpace;

- (IBAction)keepSlidenButtonTap:(UIButton *)sender;
- (IBAction)homeButtonTap:(UIButton *)sender;
- (IBAction)addPhotosButtonTap:(UIButton *)sender;
- (IBAction)rearrangeButtonTap:(UIButton *)sender;

@end
