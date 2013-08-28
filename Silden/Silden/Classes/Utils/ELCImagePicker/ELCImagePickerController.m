//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
const NSString* UIImageThumbImage = @"UIImageThumbImage";
@implementation ELCImagePickerController

@synthesize delegate = _myDelegate;

- (void)cancelImagePicker
{
	if([_myDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[_myDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

- (void)selectedAssets:(NSArray *)assets
{
	NSMutableArray *returnArray = [[[NSMutableArray alloc] init] autorelease];
    
    NSDictionary* dict = [_myDelegate imageFolderAndStartIndex];
    int i = [[dict objectForKey:@"last index"] intValue];
    NSString* baseFolder = [dict objectForKey:@"image base folder"];
    [[NSFileManager defaultManager] createDirectoryAtPath:baseFolder withIntermediateDirectories:YES attributes:nil error:nil];
    [APP_DELEGATE showActivity:YES];
    [APP_DELEGATE showLockScreenStatusWithMessage:@"Processing image"];
    float total = [assets count];
    float count = 0;
	for(ALAsset *asset in assets) {
        count++;
        [APP_DELEGATE showLockScreenStatusWithMessage:[NSString stringWithFormat:@"Processing image\n%0.2f",(count/total)*100]];
        NSAutoreleasePool* pool= [[NSAutoreleasePool alloc] init];
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		[workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        
        CGImageRef imgRef = [assetRep fullScreenImage];
        UIImage *img = [UIImage imageWithCGImage:imgRef
                                           scale:[UIScreen mainScreen].scale
                                     orientation:UIImageOrientationUp];
        NSString* filePath = [baseFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png",i++]];
        NSData * binaryImageData = UIImagePNGRepresentation(img);
        [binaryImageData writeToFile:filePath atomically:YES];
        
        [workingDictionary setObject:filePath forKey:@"UIImagePickerControllerOriginalImage"];
		[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
		[workingDictionary setObject:[UIImage imageWithCGImage:asset.thumbnail] forKey:@"UIImageThumbImage"];
		[returnArray addObject:workingDictionary];
		
		[workingDictionary release];
        [pool drain];
	}
	if(_myDelegate != nil && [_myDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_myDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:returnArray]];
	} else {
        [self popToRootViewControllerAnimated:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    NSLog(@"ELC Image Picker received memory warning.");
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc
{
    NSLog(@"deallocing ELCImagePickerController");
    [super dealloc];
}

@end
