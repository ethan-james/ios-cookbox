//
//  PhotoGalleryController.h
//  Cookbox
//
//  Created by Ethan James on 1/23/13.
//
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import "Media.h"

@interface PhotoGalleryController : UICollectionViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) Recipe *recipe;
@property (nonatomic, retain) NSArray *mediaCache;

@end
