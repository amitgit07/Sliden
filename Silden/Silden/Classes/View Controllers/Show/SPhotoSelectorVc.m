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

typedef void (^ImageFromUrl) (UIImage* image, NSString* url);
@interface SPhotoSelectorVc ()
@end

@implementation SPhotoSelectorVc {
    NSMutableArray*  allThumbs;
    NSMutableArray* allImages;
    int currentX;
    int currentY;
    BOOL anyPositionChange;
}
@synthesize workSpace=_workSpace;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        allThumbs = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.addPhotoButton setBackgroundImage:[Image(@"blueBtn37.png") stretchableImageWithLeftCapWidth:15 topCapHeight:0] forState:UIControlStateNormal];
    [self.rearrangeButton setBackgroundImage:StreachImage(@"blueBtn37.png", 15, 0) forState:UIControlStateNormal];
    
    NSArray* images = [self.workSpace.images allObjects];
    NSSortDescriptor* descriptior = [[NSSortDescriptor alloc] initWithKey:@"imageIndex" ascending:YES];
    allImages = [[NSMutableArray arrayWithArray:[images sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptior]]] retain];
    [descriptior release];
    double delayInSeconds = 0.15f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self addImagesInScrollViewFromPreviousSavedState];
    });
    anyPositionChange = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Import Photos";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [_rearrangeButton release];
    [_addPhotoButton release];
    [_scrollView release];
    cRelease(allImages);
    cRelease(allThumbs);
    cRelease(tileFrame);
    [super dealloc];
}
#pragma mark - Private methods
- (void)createVideoThumbFromImage:(NSString*)path {
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return;
    //NSLog(@"%s",__FUNCTION__);
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float rawRatio = actualWidth/actualHeight;
    float ratioRequired = Video_Thumb_W/Video_Thumb_H;
    CGSize videoSize = CGSizeMake(Video_Thumb_W, Video_Thumb_H);
    float x=0, y=0;
    
    if (rawRatio >= ratioRequired) {
        actualHeight = Video_Thumb_H;
        actualWidth *= actualHeight/image.size.height;
    }
    else {
        actualWidth = Video_Thumb_W;
        actualHeight *= actualWidth/image.size.width;
    }
    
    CGRect rect = CGRectMake(x, y, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(videoSize);
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * binaryImageData = UIImagePNGRepresentation(newImage);
    NSString* thumbPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"thumb.png"];
    [binaryImageData writeToFile:thumbPath atomically:YES];
}
- (WorkingImage*)databaseObjectForImage:(WorkingImage*)image {
    NSArray* images = [self.workSpace.images allObjects];
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        WorkingImage* obj = (WorkingImage*)evaluatedObject;
        if ([obj.imageUrl isEqualToString:image.imageUrl]) {
            return YES;
        }
        return NO;
    }];
    NSArray* result = [images filteredArrayUsingPredicate:predicate];
    return [result lastObject];
}
- (void)saveStateForImage:(WorkingImage*)image {
    NSArray* images = [self.workSpace.images allObjects];
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        WorkingImage* obj = (WorkingImage*)evaluatedObject;
        if ([obj.imageUrl isEqualToString:image.imageUrl]) {
            return YES;
        }
        return NO;
    }];
    NSArray* result = [images filteredArrayUsingPredicate:predicate];
    WorkingImage* newObj = [result lastObject];
    newObj.imageIndex = image.imageIndex;
}
- (void)removeUnwanted:(NSArray*)views {
    [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
- (void)addImagesInScrollViewFromPreviousSavedState {
    if (!anyPositionChange) {
        return;
    }
    anyPositionChange = NO;
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    //NSLog(@"%s",__FUNCTION__);
	currentX = 8;
    currentY = 8;
    if (!tileFrame) {
        tileFrame = [[NSMutableArray alloc] init];
    }
    NSArray* temp = [_scrollView subviews];
    [self performSelector:@selector(removeUnwanted:) withObject:temp afterDelay:0.5f];
    [allThumbs removeAllObjects];
    [tileFrame removeAllObjects];
    for(WorkingImage *image in allImages) {
        CGRect frame = CGRectMake(currentX, currentY, 70, 70);
        DragbleThumb* view = [[[DragbleThumb alloc] initWithFrame:frame] autorelease];
        view.workingImage = image;
        [tileFrame addObject:[NSValue valueWithCGRect:frame]];
        NSString* path = image.imageUrl;
        path = [path stringByReplacingOccurrencesOfString:@".png" withString:@"_thumb.png"];
        [view setImageFromPath:path];
        [view setThumbIndex:[image.imageIndex integerValue]];
        [view setDelegate:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_scrollView addSubview:view];
        });
        [allThumbs addObject:view];
        currentX += 78;
        if (currentX > 300) {
            currentX = 8;
            currentY += 78;
        }
    }
    [_scrollView setContentSize:CGSizeMake(320, (currentX==8)?currentY:(currentY+78))];
    [pool drain];
}
-(void)findLargeImagefromUrl:(NSString*)mediaurl performBolock:(ImageFromUrl)performBlock
{
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage* image = [UIImage imageWithCGImage:iref];
            performBlock(image, mediaurl);
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
        performBlock(nil, mediaurl);
        
    };
    
    if(mediaurl && [mediaurl length])
    {
        NSURL *asseturl = [NSURL URLWithString:mediaurl];
        ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        [assetslibrary assetForURL:asseturl
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
}
#pragma mark - Instance methods
- (IBAction)keepSlidenButtonTap:(UIButton *)sender {
    //NSLog(@"%s",__FUNCTION__);
    if ([_workSpace.images count]>1) {
        SInfoEditorVc* infoEditor = [[SInfoEditorVc alloc] initWithNibName:@"SInfoEditorVc" bundle:nil];
        [APP_DELEGATE saveContext];
        infoEditor.workSpace = self.workSpace;
        
        self.title = @"Back";
        [self.navigationController pushViewController:infoEditor animated:YES];
    }
    else {
        [SCI showAlertWithMsg:@"Please select two or more photos."];
    }
}
- (IBAction)homeButtonTap:(UIButton *)sender {
    [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
}
- (IBAction)rearrangeButtonTap:(UIButton *)sender {
    //NSLog(@"%s",__FUNCTION__);
    if ([sender.titleLabel.text isEqualToString:@"Re-arrange"]) {
        NSArray* images = [self.workSpace.images allObjects];
        cRelease(allImages);
        NSSortDescriptor* descriptior = [[NSSortDescriptor alloc] initWithKey:@"imageIndex" ascending:YES];
        allImages = [[NSMutableArray arrayWithArray:[images sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptior]]] retain];
        [descriptior release];
        [self addImagesInScrollViewFromPreviousSavedState];
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
            thumb.workingImage.imageIndex = [NSNumber numberWithInt:thumb.thumbIndex];
        }
        [APP_DELEGATE saveContext];
        [sender setTitle:@"Re-arrange" forState:UIControlStateNormal];
        [self.addPhotoButton setEnabled:YES];
        [_scrollView setScrollEnabled:YES];
    }
}
- (IBAction)addPhotosButtonTap:(UIButton *)sender {
    //NSLog(@"%s",__FUNCTION__);
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName: nil bundle: nil];
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
    [elcPicker setDelegate:self];
    [APP_DELEGATE setNavigationBarBackground:NO];
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
    //NSLog(@"%s",__FUNCTION__);
    NSManagedObjectContext* context = [APP_DELEGATE managedObjectContext];
    WorkingImage* _workImage = [NSEntityDescription insertNewObjectForEntityForName:@"WorkingImage" inManagedObjectContext:context];
    _workImage.imageAdded = [NSDate date];
    _workImage.imageIndex = [NSNumber numberWithInt:index];
    _workImage.imageUrl = path;
    _workImage.inWorkSpace = [NSSet setWithObject:_workSpace];
    return _workImage;
}
- (NSDictionary*)imageFolderAndStartIndex {
    NSString* workingFolder = CACHE_DIR;
    int lastIndex = 0;
    workingFolder = [workingFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_workSpace.dateCreated]];
    lastIndex = [allImages count];
    return [NSDictionary dictionaryWithObjectsAndKeys:workingFolder,@"image base folder",
            [NSNumber numberWithInt:lastIndex],@"last index", nil];
}
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
	
    int lastIndex = 0;
    lastIndex = [allImages count];
    NSString* workingFolder = CACHE_DIR;
    workingFolder = [workingFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_workSpace.dateCreated]];
    NSString* filePath = nil;
    BOOL makeThumbToo = YES;
	for(NSDictionary *dict in info) {
        _workSpace.isAnyChange = [NSNumber numberWithInt:([_workSpace.isAnyChange integerValue] | WorkSpaceChangedInPhotosSelection)];
        filePath = [dict objectForKey:UIImagePickerControllerOriginalImage];//[workingFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png",lastIndex]];
        
        UIImage* image = [dict objectForKey:UIImageThumbImage];//UIImagePickerControllerOriginalImage
        NSString *thumbPath = [workingFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_thumb.png",lastIndex]];
        NSData * binaryImageData = UIImagePNGRepresentation(image);
        [binaryImageData writeToFile:thumbPath atomically:YES];
        if (makeThumbToo) {
            [self createVideoThumbFromImage:filePath];
            makeThumbToo = NO;
        }
        DragbleThumb* view = [[DragbleThumb alloc] initWithFrame:CGRectMake(currentX, currentY, 70, 70)];
        [view.imageThumb setImage:image];
        [_scrollView addSubview:view];
        [allThumbs addObject:view];
        [tileFrame addObject:[NSValue valueWithCGRect:view.frame]];
        
        
        WorkingImage* lastThumb = [self addNewImageAtPath:filePath andIndex:lastIndex];
        [lastThumb setAssetsUrl:[(NSURL*)[dict objectForKey:UIImagePickerControllerReferenceURL] absoluteString]];
        [allImages addObject:lastThumb];
        [view setThumbIndex:[lastThumb.imageIndex integerValue]];
        [view setDelegate:self];
        [view setWorkingImage:lastThumb];
        
        currentX += 78;
        if (currentX > 300) {
            currentX = 8;
            currentY += 78;
        }
        lastIndex++;
	}
    [_scrollView setContentSize:CGSizeMake(320, (currentX==8)?currentY:(currentY+78))];
    [APP_DELEGATE showActivity:NO];
    [APP_DELEGATE saveContext];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
    [APP_DELEGATE setNavigationBarBackground:NO];
}

#pragma mark - DragableView Delegate
- (void)dragbleThumb:(DragbleThumb*)thumb didBeginFromPosition:(CGPoint)point {
    //NSLog(@"%s",__FUNCTION__);
    heldTile = thumb;
    
    touchStartLocation = point;
    heldStartPosition = thumb.frame.origin;
    heldFrameIndex = [allThumbs indexOfObject:thumb];
    
    [self.scrollView bringSubviewToFront:thumb];
    [thumb appearDraggable];
    //[self startTilesWiggling];
    anyPositionChange = YES;
    _workSpace.isAnyChange = [NSNumber numberWithInt:([_workSpace.isAnyChange integerValue] | WorkSpaceChangedInPhotosSelection)];
}
- (void)dragbleThumb:(DragbleThumb*)thumb didMovingToPosition:(CGPoint)point {
    //NSLog(@"%s",__FUNCTION__);
    if (heldTile) {
        [self moveHeldTileToPoint:point];
        [self moveUnheldTilesAwayFromPoint:point];
    }
}
- (void)moveHeldTileToPoint:(CGPoint)location {
    //NSLog(@"%s",__FUNCTION__);
    float dx = location.x - touchStartLocation.x;
    float dy = location.y - touchStartLocation.y;
    CGPoint newPosition = CGPointMake(heldStartPosition.x + dx, heldStartPosition.y + dy);
    CGRect frame = CGRectMake(newPosition.x, newPosition.y, 70, 70);
    [UIView beginAnimations:@"move" context:nil];
    heldTile.frame = frame;
    [UIView commitAnimations];
}
- (void)moveUnheldTilesAwayFromPoint:(CGPoint)location {
    //NSLog(@"%s",__FUNCTION__);
    int frameIndex = [self indexOfClosestFrameToPoint:location];
    
    if (frameIndex != heldFrameIndex) {
        [UIView beginAnimations:@"MoveTiles" context:nil];
        
        if (frameIndex < heldFrameIndex) {
            for (int i = heldFrameIndex; i > frameIndex; --i) {
                DragbleThumb *movingTile = allThumbs[i-1];
                movingTile.frame = [(NSValue*)tileFrame[i] CGRectValue];
                movingTile.thumbIndex = i;
                movingTile.workingImage.imageIndex = [NSNumber numberWithInt:i];
                allThumbs[i] = movingTile;
                NSLog(@"prev - %d (%d, heldFrameIndex=%d)",i, frameIndex,heldFrameIndex);
            }
        }
        else if (heldFrameIndex < frameIndex) {
            for (int i = heldFrameIndex; i < frameIndex; ++i) {
                DragbleThumb *movingTile = allThumbs[i+1];
                movingTile.frame = [(NSValue*)tileFrame[i] CGRectValue];
                movingTile.thumbIndex = i;
                movingTile.workingImage.imageIndex = [NSNumber numberWithInt:i];
                allThumbs[i] = movingTile;
                NSLog(@"next - %d (%d, heldFrameIndex=%d)",i, frameIndex, heldFrameIndex);
            }
        }
        heldFrameIndex = frameIndex;
        allThumbs[heldFrameIndex] = heldTile;
        heldTile.thumbIndex = heldFrameIndex;
        heldTile.workingImage.imageIndex = [NSNumber numberWithInt:heldFrameIndex];
        
        [UIView commitAnimations];
    }
}
- (int)indexOfClosestFrameToPoint:(CGPoint)point {
    //NSLog(@"%s",__FUNCTION__);
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
    //NSLog(@"%s",__FUNCTION__);
    [heldTile appearNormal];
    if (heldTile && heldFrameIndex < [tileFrame count]) {
        heldTile.frame = [(NSValue*)tileFrame[heldFrameIndex] CGRectValue];
        heldTile.thumbIndex = heldFrameIndex;
        heldTile.workingImage.imageIndex = [NSNumber numberWithInt:heldFrameIndex];
        heldTile = nil;
    }
}
- (void)startTilesWiggling {
    //NSLog(@"%s",__FUNCTION__);
    for (DragbleThumb* thumb in allThumbs) {
        if (thumb != heldTile) {
            thumb.layer.cornerRadius =5.0f;
            [thumb.layer setMasksToBounds:YES];
            [thumb startWiggling];
        }
    }
}


- (void)stopTilesWiggling {
    //    //NSLog(@"%s",__FUNCTION__);
    //    [allImages removeAllObjects];
    //    int index = 0;
    //    for (DragbleThumb* thumb in allThumbs) {
    //        [thumb stopWiggling];
    //        WorkingImage* image = thumb.workingImage;
    //        image.imageIndex = [NSNumber numberWithInt:index++];
    //        [allImages addObject:thumb.workingImage];
    //        thumb.layer.cornerRadius =0.0f;
    //    }
    //    [APP_DELEGATE saveContext];
}
- (void)didTapToEditDragbleThumb:(DragbleThumb*)thumb {
    //NSLog(@"%s",__FUNCTION__);
    [thumb appearNormal];
    if (thumb.isDraggingEnabled) {
        return;
    }
    _beingEditedImage = thumb;
    UIImage* image = [UIImage imageWithContentsOfFile:thumb.workingImage.imageUrl];
    [self launchPhotoEditorWithImage:image highResolutionImage:nil];
}


- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage {
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[[AFPhotoEditorController alloc] initWithImage:editingResImage] autorelease];
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
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSData * binaryImageData = UIImagePNGRepresentation(image);
    [binaryImageData writeToFile:_beingEditedImage.workingImage.imageUrl atomically:YES];
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float requiredH = 150.0f;
    float requiredW = 150.0f;
    float rawRatio = actualWidth/actualHeight;
    float ratioRequired = requiredW/requiredH;
    CGSize videoSize = CGSizeMake(requiredW, requiredH);
    float x=0, y=0;
    
    if (rawRatio >= ratioRequired) {
        actualHeight = requiredH;
        actualWidth *= actualHeight/image.size.height;
    }
    else {
        actualWidth = requiredW;
        actualHeight *= actualWidth/image.size.width;
    }
    
    CGRect rect = CGRectMake(x, y, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(videoSize);
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    binaryImageData = UIImagePNGRepresentation(newImage);
    NSString* path = [_beingEditedImage.workingImage.imageUrl stringByReplacingOccurrencesOfString:@".png" withString:@"_thumb.png"];
    [binaryImageData writeToFile:path atomically:YES];
    
    [_beingEditedImage.imageThumb setImage:newImage];
    
}

- (void) photoEditorCanceled:(AFPhotoEditorController *)editor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions {
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
