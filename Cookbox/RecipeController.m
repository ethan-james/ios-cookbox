//
//  RecipeController.m
//  Cookbox
//
//  Created by Ethan James on 1/4/13.
//
//

#import "RecipeController.h"

@interface RecipeController ()

@end

@implementation RecipeController

@synthesize webView;
@synthesize recipe = _recipe;
@synthesize recipeURL = _recipeURL;

#pragma mark accessors

- (void)setRecipe:(Recipe *)recipe {
    _recipeURL = nil;
    _recipe = recipe;
}

- (void)setRecipeURL:(NSURL *)recipeURL {
    _recipe = nil;
    _recipeURL = recipeURL;
}

#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSError *error;
    [super viewDidLoad];
    
    if ([self recipe] != nil) {
        [webView loadHTMLString:[[self recipe] asHTML] baseURL:[NSURL URLWithString:@"/"]];
    } else if ([self recipeURL] != nil) {
        NSString *html = [NSString stringWithContentsOfURL:[self recipeURL] encoding:NSStringEncodingConversionAllowLossy error:&error];
        NSString *contentPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"scraper.html"];
        NSString *host = [[[self recipeURL] host] stringByReplacingOccurrencesOfString:@"www." withString:@""];
        NSString *scraperPath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"scrapers"] stringByAppendingPathComponent:[host stringByAppendingPathExtension:@"mdown"]];
        NSString *content = [NSString stringWithContentsOfFile:contentPath encoding:NSStringEncodingConversionAllowLossy error:&error];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:scraperPath]) {
            NSString *scraper = [NSString stringWithContentsOfFile:scraperPath encoding:NSStringEncodingConversionAllowLossy error:&error];

            content = [content stringByReplacingOccurrencesOfString:@"<%= $scraper %>" withString:scraper];
            content = [content stringByReplacingOccurrencesOfString:@"<%= $html %>" withString:html];

            [[self webView] loadHTMLString:content baseURL:[NSURL fileURLWithPath:contentPath]];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Can't read recipe" message:@"This page is not recognized as a recipe." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    NSLog(@"hmm?");
    NSLog(@"%@", [[self webView] stringByEvaluatingJavaScriptFromString:@"scrape()"]);
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
}

@end
