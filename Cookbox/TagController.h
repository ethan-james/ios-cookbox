//
//  TagControllerViewController.h
//  Cookbox
//
//  Created by Ethan James on 1/22/13.
//
//

#import "Recipe.h"
#import <UIKit/UIKit.h>

@interface TagController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, retain) Recipe *recipe;

@end
