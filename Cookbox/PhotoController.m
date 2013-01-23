//
//  PhotoController.m
//  Cookbox
//
//  Created by Ethan James on 1/23/13.
//
//

#import "PhotoController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface PhotoController ()

@end

@implementation PhotoController

@synthesize imageSrc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    UIImageView *v = (UIImageView *)[[self view] viewWithTag:100];
    [super viewDidLoad];

    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *myError) {
        NSLog(@"ruh roh 2");
    };
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *myAsset) {
        ALAssetRepresentation *rep = [myAsset defaultRepresentation];
        [v setImage:[UIImage imageWithCGImage:[rep fullResolutionImage] scale:1.0 orientation:UIImageOrientationUp]];
    };
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:[NSURL URLWithString:imageSrc] resultBlock:resultBlock failureBlock:failureBlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
