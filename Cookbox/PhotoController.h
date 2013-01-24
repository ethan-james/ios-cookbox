//
//  PhotoController.h
//  Cookbox
//
//  Created by Ethan James on 1/23/13.
//
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface PhotoController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (nonatomic, retain) Recipe *recipe;

@end
