//
//  RecipeController.m
//  Cookbox
//
//  Created by Ethan James on 1/4/13.
//
//

#import "RecipeController.h"
#import "RecipeSource.h"
#import "AppDelegate.h"
#import <QuartzCore/CALayer.h>

@interface RecipeController ()

@end

@implementation RecipeController

@synthesize webView;
@synthesize recipe = _recipe;
@synthesize recipeURL = _recipeURL;
@synthesize ratingWidget;

- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

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
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveRecipe)];
    UIBarButtonItem *tagsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(tags)];
    NSString *scrapersDirectory = [[[[self appDelegate] applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"scrapers"];
    
    ratingWidget.starImage = [UIImage imageNamed:@"star.png"];
    ratingWidget.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    ratingWidget.maxRating = 5.0;
    ratingWidget.delegate = self;
    ratingWidget.horizontalMargin = 0;
    ratingWidget.editable=YES;
    ratingWidget.displayMode=EDStarRatingDisplayHalf;

    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, tagsButton, nil];
    
    if ([self recipe] != nil) {
        NSError *error;
        NSString *recipe = [[self recipe] asHTML];
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        NSString *recipeTemplate = [NSString stringWithContentsOfFile:[[baseURL URLByAppendingPathComponent:@"recipe-template.html"] path] encoding:NSUTF8StringEncoding error:&error];

        [webView loadHTMLString:[recipeTemplate stringByReplacingOccurrencesOfString:@"<%= $recipe %>" withString:recipe] baseURL:baseURL];
    } else if ([self recipeURL] != nil) {
        NSString *html = [NSString stringWithContentsOfURL:[self recipeURL] encoding:NSUTF8StringEncoding error:&error];
        NSString *contentPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"scraper.html"];
        NSString *host = [[[self recipeURL] host] stringByReplacingOccurrencesOfString:@"www." withString:@""];
        NSString *scraperPath = [scrapersDirectory stringByAppendingPathComponent:[host stringByAppendingPathExtension:@"mdown"]];
        NSString *content = [NSString stringWithContentsOfFile:contentPath encoding:NSUTF8StringEncoding error:&error];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:scraperPath]) {
            NSData *data = [NSData dataWithContentsOfFile:scraperPath];
            NSString *scraper = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            content = [content stringByReplacingOccurrencesOfString:@"<%= $scraper %>" withString:scraper];
            content = [content stringByReplacingOccurrencesOfString:@"<%= $html %>" withString:html];
            content = [content stringByReplacingOccurrencesOfString:@"<%= $scraper_url %>" withString:[[self recipeURL] absoluteString]];

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

#pragma mark nav buttons

- (void)saveRecipe {
    [[self recipe] save];
}

- (void)tags {
    [self performSegueWithIdentifier:@"OpenTags" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"OpenTags" isEqualToString:segue.identifier]) {
        [segue.destinationViewController setRecipe:[self recipe]];
    }
}

#pragma mark UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    if ([self recipe] == nil) {
        NSString *markdown = [[self webView] stringByEvaluatingJavaScriptFromString:@"scrape()"];
        Recipe *recipe = [Recipe new];
        RecipeSource *recipeSource = [RecipeSource new:[[self recipeURL] absoluteString] fromSource:@"web"];
    
        [recipe update:markdown];
        [recipeSource setRecipe:recipe];
        
        [self setRecipe:recipe];

        [webView loadHTMLString:[recipe asHTML] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark EDStarRating delegate

- (void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating {
    [self.recipe changeRating:[NSNumber numberWithFloat:rating]];
}

@end
