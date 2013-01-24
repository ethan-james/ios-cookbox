//
//  TagControllerViewController.m
//  Cookbox
//
//  Created by Ethan James on 1/22/13.
//
//

#import "Tag.h"
#import "TagController.h"
#import "AppDelegate.h"

@interface TagController ()

@end

@implementation TagController

NSArray *tags;
NSArray *taggedCache;
NSInteger deleteRow = -1;

@synthesize recipe;
@synthesize search;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    tags = [[NSArray alloc] init];
    [self reload];
}

- (void)reload {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES];
    taggedCache = [[recipe tags] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    [search setText:@""];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tags count] + [taggedCache count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.row < [tags count]) {
        [cell.textLabel setText:[tags objectAtIndex:indexPath.row]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        Tag *t = [taggedCache objectAtIndex:indexPath.row - [tags count]];
        [cell.textLabel setText:[t tag]];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [tags count]) {
        Tag *tag = [Tag findOrCreate:[tags objectAtIndex:indexPath.row]];
        [tag addRecipesObject:recipe];
        [tag save];
        deleteRow = -1;
        [self reload];
    } else {
        NSInteger index = indexPath.row - [tags count];
        Tag *t = [taggedCache objectAtIndex:index];
        NSString *msg = [NSString stringWithFormat:@"Do you want to remove %@?", [t tag]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove tag?" message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        deleteRow = index;
        [alert show];
    }
}

#pragma mark UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 1) {
        NSString *tag = [NSString stringWithFormat:@"#%@", searchText];
        NSArray *tagArray = [[Tag search:tag] mutableArrayValueForKey:@"tag"];

        if ([tagArray indexOfObject:tag] == NSNotFound) {
            tags = [[NSArray arrayWithObject:tag] arrayByAddingObjectsFromArray:tagArray];
        } else {
            tags = tagArray;
        }
    } else {
        tags = [[NSArray alloc] init];
    }

    [self.tableView reloadData];
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSError *error;
        AppDelegate *ad = [[UIApplication sharedApplication] delegate];
        Tag *t = [taggedCache objectAtIndex:deleteRow];
        [recipe removeTagsObject:t];
        [[ad managedObjectContext] save:&error];
        [self reload];
    }
}

@end
