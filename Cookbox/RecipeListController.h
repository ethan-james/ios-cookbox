//
//  RecipeListController.h
//  Cookbox
//
//  Created by Ethan James on 1/2/13.
//
//

#import "EDStarRating.h"
#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

enum {
    RMAlphaSort = 0,
    RMTagSort,
    RMRatingsSort
};
typedef NSUInteger RMSortMode;

@interface RecipeListController : UITableViewController <DBRestClientDelegate, UISearchBarDelegate, UISearchDisplayDelegate, EDStarRatingProtocol>
    @property (nonatomic, retain) NSArray *recipes;
    @property (nonatomic, retain) NSArray *tagList;
    @property (nonatomic, retain, readonly) IBOutlet UISearchBar *search;

    - (void)syncRecipes;
@end
