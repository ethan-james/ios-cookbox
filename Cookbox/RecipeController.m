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
@synthesize recipe;

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
    [super viewDidLoad];
	[webView loadHTMLString:[recipe asHTML] baseURL:[NSURL URLWithString:@"/"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
