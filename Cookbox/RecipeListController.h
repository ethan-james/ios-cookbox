//
//  RecipeListController.h
//  Cookbox
//
//  Created by Ethan James on 1/2/13.
//
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface RecipeListController : UITableViewController <DBRestClientDelegate>
    @property (nonatomic, retain) NSArray *recipes;

    - (void)syncRecipes;
@end
