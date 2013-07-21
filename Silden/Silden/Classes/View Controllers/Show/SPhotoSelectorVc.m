//
//  SPhotoSelectorVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 21/06/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SPhotoSelectorVc.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import "SInfoEditorVc.h"

#import <QuartzCore/QuartzCore.h>
#import "AFPhotoEditorController.h"
#import "AFPhotoEditorCustomization.h"


@interface SPhotoSelectorVc ()
@end

@implementation SPhotoSelectorVc {
    NSMutableArray*  allThumbs;
    NSMutableArray* allImages;
    int currentX;
    int currentY;
}
@synthesize workSpace=_workSpace;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        allThumbs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.addPhotoButton setBackgroundImage:[Image(@"blueBtn37.png") stretchableImageWithLeftCapWidth:15 topCapHeight:0] forState:UIControlStateNormal];
    [self.rearrangeButton setBackgroundImage:StreachImage(@"blueBtn37.png", 15, 0) forState:UIControlStateNormal];    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray* images = [self.workSpace.images allObjects];
    NSSortDescriptor* descriptior = [[NSSortDescriptor alloc] initWithKey:@"imageIndex" ascending:YES];
    allImages = [[NSMutableArray arrayWithArray:[images sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptior]]] retain];
    [descriptior release];
    [self addImagesInScrollViewFromPreviousSavedState];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [_rearrangeButton release];
    [_addPhotoButton release];
    [_scrollView release];
    [super dealloc];
}
#pragma mark - Private methods
- (void)addImagesInScrollViewFromPreviousSavedState {
	currentX = 8;
    currentY = 8;
    if (!tileFrame) {
        tileFrame = [[NSMutableArray alloc] init];
    }
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	for(WorkingImage *image in allImages) {
        CGRect frame = CGRectMake(currentX, currentY, 70, 70);
        DragbleThumb* view = [[DragbleThumb alloc] initWithFrame:frame];
        view.workingImage = image;
        [tileFrame addObject:[NSValue valueWithCGRect:frame]];
        [view.imageThumb setImage:[UIImage imageWithContentsOfFile:image.imageUrl]];
        [_scrollView addSubview:view];
        [allThumbs addObject:view];
        [view setThumbIndex:[image.imageIndex integerValue]];
        [view setDelegate:self];
        currentX += 78;
        if (currentX > 300) {
            currentX = 8;
            currentY += 78;
        }
        [_scrollView setContentSize:CGSizeMake(320, (currentX==8)?currentY:(currentY+78))];
	}
}
- (void)prepareToRearrange {
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:0.0f]];
    [anim setFromValue:[NSNumber numberWithDouble:M_PI/16]]; // rotation angle
    [anim setDuration:0.1];
    [anim setRepeatCount:4];
    [anim setAutoreverses:YES];
    //[self.viewYouAreShaking.layer addAnimation:anim forKey:@"iconShake"];
}
- (CGRect)frameForThumbAtIndex:(int)index {
    int row = index % 4;
    int column = (int)floor(index/4);
    return CGRectMake(row*78+8, column*78+8, 70, 70);
}
- (void)repositionTumbAtIndex:(int)from toIndex:(int)to {
    if (from < to) {//going down
        for (int i = from; i<to; i++) {
            DragbleThumb* thumb = allThumbs[i];
            [UIView animateWithDuration:0.2f animations:^{
                [thumb setFrame:[self frameForThumbAtIndex:i-1]];
                thumb.thumbIndex--;
            }];
        }
        DragbleThumb* thumb = allThumbs[from];
        thumb.thumbIndex = to;
    }
    else {
        
    }
}
#pragma mark - Instance methods
- (IBAction)keepSlidenButtonTap:(UIButton *)sender {
    SInfoEditorVc* infoEditor = [[SInfoEditorVc alloc] initWithNibName:@"SInfoEditorVc" bundle:nil];
    [APP_DELEGATE saveContext];
    infoEditor.workSpace = self.workSpace;
    [self.navigationController pushViewController:infoEditor animated:YES];
}

- (IBAction)homeButtonTap:(UIButton *)sender {
    [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
}



- (IBAction)rearrangeButtonTap:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"Re-arrange"]) {
        for (DragbleThumb* thumb in allThumbs) {
            [thumb setIsDraggingEnabled:YES];
        }
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self.addPhotoButton setEnabled:NO];
        [_scrollView setScrollEnabled:NO];
    }
    else {
        for (DragbleThumb* thumb in allThumbs) {
            [thumb setIsDraggingEnabled:NO];
        }
        [sender setTitle:@"Re-arrange" forState:UIControlStateNormal];
        [self.addPhotoButton setEnabled:YES];
        [_scrollView setScrollEnabled:YES];
    }
}
- (IBAction)addPhotosButtonTap:(UIButton *)sender {
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName: nil bundle: nil];
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
    [elcPicker setDelegate:self];
    
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
        [self presentViewController:elcPicker animated:YES completion:nil];
    } else {
        [self presentModalViewController:elcPicker animated:YES];
    }
    
    [elcPicker release];
    [albumController release];
}
#pragma mark ELCImagePickerControllerDelegate Methods
- (WorkingImage*)addNewImageAtPath:(NSString*)path andIndex:(int)index {
    NSManagedObjectContext* context = [APP_DELEGATE managedObjectContext];
    WorkingImage* _workImage = [NSEntityDescription insertNewObjectForEntityForName:@"WorkingImage" inManagedObjectContext:context];
    _workImage.imageAdded = [NSDate date];
    _workImage.imageIndex = [NSNumber numberWithInt:index];
    _workImage.imageUrl = path;
    _workImage.inWorkSpace = [NSSet setWithObject:_workSpace];
    return _workImage;
}
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
	
    int lastIndex = 0;
    if ([allImages count]) {
        WorkingImage* lastThumb = [allImages lastObject];
        lastIndex = [lastThumb.imageIndex intValue]+1;
    }
    NSString* workingFolder = DOC_DIR;
    workingFolder = [workingFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_workSpace.dateCreated]];
    NSString* filePath = nil;
	for(NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        filePath = [workingFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png",lastIndex]];
        NSData * binaryImageData = UIImagePNGRepresentation(image);
        [binaryImageData writeToFile:filePath atomically:YES];
		
        DragbleThumb* view = [[DragbleThumb alloc] initWithFrame:CGRectMake(currentX, currentY, 70, 70)];
        [view.imageThumb setImage:[dict objectForKey:@"UIImageThumbImage"]];
        [_scrollView addSubview:view];
        [allThumbs addObject:view];
        WorkingImage* lastThumb = [self addNewImageAtPath:filePath andIndex:lastIndex];
        [allImages addObject:lastThumb];
        [view setThumbIndex:[lastThumb.imageIndex integerValue]];
        [view setDelegate:self];
        
        currentX += 78;
        if (currentX > 300) {
            currentX = 8;
            currentY += 78;
        }
        lastIndex++;
	}
    [_scrollView setContentSize:CGSizeMake(320, (currentX==8)?currentY:(currentY+78))];
    [APP_DELEGATE saveContext];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
    [APP_DELEGATE setNavigationBarBackground:YES];
}

#pragma mark - DragableView Delegate 
- (void)dragbleThumb:(DragbleThumb*)thumb didBeginFromPosition:(CGPoint)point {
    heldTile = thumb;
    
    touchStartLocation = point;
    heldStartPosition = thumb.frame.origin;
    heldFrameIndex = thumb.thumbIndex;
    
    [self.scrollView bringSubviewToFront:thumb];
    [thumb appearDraggable];
    [self startTilesWiggling];
}
- (void)dragbleThumb:(DragbleThumb*)thumb didMovingToPosition:(CGPoint)point {
    if (heldTile) {
        [self moveHeldTileToPoint:point];
        [self moveUnheldTilesAwayFromPoint:point];
    }
}
- (void)moveHeldTileToPoint:(CGPoint)location {
    float dx = location.x - touchStartLocation.x;
    float dy = location.y - touchStartLocation.y;
    CGPoint newPosition = CGPointMake(heldStartPosition.x + dx, heldStartPosition.y + dy);
    CGRect frame = CGRectMake(newPosition.x, newPosition.y, 70, 70);
    [UIView beginAnimations:@"move" context:nil];
    heldTile.frame = frame;
    [UIView commitAnimations];
}
- (void)moveUnheldTilesAwayFromPoint:(CGPoint)location {
    int frameIndex = [self indexOfClosestFrameToPoint:location];

    if (frameIndex != heldFrameIndex) {
        [UIView beginAnimations:@"MoveTiles" context:nil];
        
        if (frameIndex < heldFrameIndex) {
            for (int i = heldFrameIndex; i > frameIndex; --i) {
                DragbleThumb *movingTile = allThumbs[i-1];
                movingTile.frame = [(NSValue*)tileFrame[i] CGRectValue];
                movingTile.thumbIndex = i;
                allThumbs[i] = movingTile;
                NSLog(@"prev - %d (%d, heldFrameIndex=%d)",i, frameIndex,heldFrameIndex);
            }
        }
        else if (heldFrameIndex < frameIndex) {
            for (int i = heldFrameIndex; i < frameIndex; ++i) {
                DragbleThumb *movingTile = allThumbs[i+1];
                movingTile.frame = [(NSValue*)tileFrame[i] CGRectValue];
                movingTile.thumbIndex = i;
                allThumbs[i] = movingTile;
                NSLog(@"next - %d (%d, heldFrameIndex=%d)",i, frameIndex, heldFrameIndex);
            }
        }
        heldFrameIndex = frameIndex;
        allThumbs[heldFrameIndex] = heldTile;
        heldTile.thumbIndex = heldFrameIndex;
        [UIView commitAnimations];
    }
}
- (int)indexOfClosestFrameToPoint:(CGPoint)point {
    int index = 0;
    float minDist = FLT_MAX;
    int i = 0;
    for (NSValue* rFrame in tileFrame) {
        CGRect frame = [(NSValue*)tileFrame[i] CGRectValue];
        
        float dx = point.x - CGRectGetMidX(frame);
        float dy = point.y - CGRectGetMidY(frame);
        
        float dist = (dx * dx) + (dy * dy);
        if (dist < minDist) {
            index = i;
            minDist = dist;
        }
        i++;
    }
    return index;
}

- (void)dragbleThumb:(DragbleThumb*)thumb didEndOnPosition:(CGPoint)point {
    if (heldTile) {
        [heldTile appearNormal];
        heldTile.frame = [(NSValue*)tileFrame[heldFrameIndex] CGRectValue];
        heldTile.thumbIndex = heldFrameIndex;
        heldTile = nil;
        [self stopTilesWiggling];
    }
}
- (void)startTilesWiggling {
    for (DragbleThumb* thumb in allThumbs) {
        if (thumb != heldTile) {
            [thumb startWiggling];
        }
    }
}


- (void)stopTilesWiggling {
    for (DragbleThumb* thumb in allThumbs) {
        [thumb stopWiggling];
    }
}
- (void)didTapToEditDragbleThumb:(DragbleThumb*)thumb {
    _beingEditedImage = thumb;
    UIImage* image = [UIImage imageWithContentsOfFile:thumb.workingImage.imageUrl];
    [self launchPhotoEditorWithImage:image highResolutionImage:nil];
}


- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    [self presentViewController:photoEditor animated:YES completion:nil];
}
#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [_beingEditedImage.imageThumb setImage:image];
    NSData * binaryImageData = UIImagePNGRepresentation(image);
    [binaryImageData writeToFile:_beingEditedImage.workingImage.imageUrl atomically:YES];

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set Accent Color
    [AFPhotoEditorCustomization setOptionValue:[UIColor colorWithRed:(159.0f/255.0f) green:(105.0f/255.0f) blue:(201.0f/255.0f) alpha:1.0f] forKey:@"editor.accentColor"];
    
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFBrightness, kAFContrast, kAFSaturation, kAFSharpness, kAFDraw, kAFText,
                            kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setOptionValue:toolOrder forKey:@"editor.toolOrder"];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setOptionValue:@NO forKey:@"editor.tool.crop.enableOriginal"];
    [AFPhotoEditorCustomization setOptionValue:@YES forKey:@"editor.tool.crop.enableCustom"];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setOptionValue:@[square, fourBySix, fiveBySeven] forKey:@"editor.tool.crop.presets"];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setOptionValue:supportedOrientations forKey:@"editor.supportedOrientations"];
    }
}


@end
