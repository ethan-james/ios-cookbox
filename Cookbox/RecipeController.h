//
//  RecipeController.h
//  Cookbox
//
//  Created by Ethan James on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface RecipeController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
    @property (retain,nonatomic) IBOutlet UIWebView *webView;
    @property (retain,nonatomic) Recipe *recipe;
    @property (retain,nonatomic) NSURL *recipeURL;
@end
