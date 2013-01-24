//
//  PhotoGalleryController.m
//  Cookbox
//
//  Created by Ethan James on 1/23/13.
//
//

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "PhotoGalleryController.h"
#import "PhotoController.h"

@interface PhotoGalleryController ()

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@end

@implementation PhotoGalleryController

@synthesize recipe;
@synthesize mediaCache;

NSArray *sortArray;

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
    [super viewDidLoad];
	
    UIBarButtonItem *addPhoto = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
    
    self.navigationItem.rightBarButtonItem = addPhoto;
    sortArray = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]];
    
    [self reloadMedia];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark nav

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
    [self dismissModalViewControllerAnimated:YES];
    [self reloadMedia];
}

#pragma mark data source

- (void)reloadMedia {
    [self setMediaCache:[recipe.media sortedArrayUsingDescriptors:sortArray]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [recipe.media count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Media *media = [mediaCache objectAtIndex:indexPath.row];
    UIImageView *thumb = (UIImageView *)[cell viewWithTag:100];
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *myError) {
        NSLog(@"ruh roh");
    };
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *myAsset) {
        [thumb setImage:[UIImage imageWithCGImage:[myAsset thumbnail]]];
    };
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:[NSURL URLWithString:media.url] resultBlock:resultBlock failureBlock:failureBlock];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
    [self performSegueWithIdentifier:@"ViewPhoto" sender:[collectionView cellForItemAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UICollectionViewCell *)sender {
    if ([@"ViewPhoto" isEqualToString:segue.identifier]) {
        PhotoController *c = [segue destinationViewController];
        NSIndexPath *indexPath = [[self collectionView] indexPathForCell:sender];
        Media *media = [mediaCache objectAtIndex:indexPath.row];
//        [c setImageSrc:[media url]];
    }
}

@end
