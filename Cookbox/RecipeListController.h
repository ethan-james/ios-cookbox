//
//  RecipeListController.h
//  Cookbox
//
//  Created by Ethan James on 1/2/13.
//
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface RecipeListController : UITableViewController <DBRestClientDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
    @property (nonatomic, retain) NSArray *recipes;
    @property (nonatomic, retain, readonly) IBOutlet UISearchBar *search;

    - (void)syncRecipes;
@end
