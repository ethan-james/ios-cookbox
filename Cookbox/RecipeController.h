//
//  RecipeController.h
//  Cookbox
//
//  Created by Ethan James on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface RecipeController : UIViewController
    @property (retain,nonatomic) IBOutlet UIWebView *webView;
    @property (retain,nonatomic) Recipe *recipe;
@end
