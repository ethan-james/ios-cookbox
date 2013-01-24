//
//  TagControllerViewController.h
//  Cookbox
//
//  Created by Ethan James on 1/22/13.
//
//

#import "Recipe.h"
#import <UIKit/UIKit.h>

@interface TagController : UITableViewController <UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) Recipe *recipe;
@property (nonatomic, readonly, retain) IBOutlet UISearchBar *search;

@end
