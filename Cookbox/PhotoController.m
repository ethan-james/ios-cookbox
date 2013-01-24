//
//  PhotoController.m
//  Cookbox
//
//  Created by Ethan James on 1/23/13.
//
//

#import "PhotoController.h"
#import "Media.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface PhotoController ()

@end

@implementation PhotoController

@synthesize recipe;
NSInteger current;

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
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
    
    current = 0;
    self.navigationItem.rightBarButtonItem = addButton;
    [self reload];
}

- (void)loadMedia:(NSInteger)i {
    UIImageView *v = (UIImageView *)[[self view] viewWithTag:100];
    NSArray *sort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES]];
    Media *m = [[[[self recipe] media] sortedArrayUsingDescriptors:sort] objectAtIndex:i];
    
    [super viewDidLoad];
    
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *myError) {
        NSLog(@"ruh roh 2");
    };
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *myAsset) {
        ALAssetRepresentation *rep = [myAsset defaultRepresentation];
        [v setImage:[UIImage imageWithCGImage:[rep fullResolutionImage] scale:1.0 orientation:UIImageOrientationUp]];
    };
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:[NSURL URLWithString:m.url] resultBlock:resultBlock failureBlock:failureBlock];
}

- (void)reload {
    NSInteger total = [[recipe media] count];

    if (total > 0) {
        NSString *title = [NSString stringWithFormat:@"Viewing %d / %d", current + 1, total];
        [self loadMedia:current];
        [self setTitle:title];
    } else {
        [self setTitle:@"No images!"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark nav

- (void)swipeLeft:(UISwipeGestureRecognizer *)g {
    current = (current + 1) % [[recipe media] count];
    [self reload];
    [self loadMedia:current];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)g {
    current = current - 1;
    if (current < 0) current = [[recipe media] count] - 1;
    
    [self reload];
    [self loadMedia:current];
}

- (void)addPhoto {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    Media *media = [Media new:[url absoluteString]];
    
    [media setRecipe:recipe];
    [media setCreated_at:[NSDate date]];
    [media save];
    current = [[recipe media] count] - 1;
    [self dismissModalViewControllerAnimated:YES];
    [self reload];
}


@end
