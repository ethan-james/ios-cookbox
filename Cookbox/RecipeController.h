//
//  RecipeController.h
//  Cookbox
//
//  Created by Ethan James on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import "EDStarRating.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface RecipeController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, EDStarRatingProtocol, MFMailComposeViewControllerDelegate>
    @property (retain,nonatomic) IBOutlet UIWebView *webView;
    @property (retain,nonatomic) IBOutlet EDStarRating *ratingWidget;
    @property (retain,nonatomic) Recipe *recipe;
    @property (retain,nonatomic) NSURL *recipeURL;
@end
