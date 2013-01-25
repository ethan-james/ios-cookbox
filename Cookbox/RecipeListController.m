//
//  RecipeListController.m
//  Cookbox
//
//  Created by Ethan James on 1/2/13.
//
//

#import "RecipeListController.h"
#import "RecipeController.h"
#import <DropboxSDK/DBDeltaEntry.h>
#import "Recipe.h"
#import "Tag.h"

@interface RecipeListController ()

@end

@implementation RecipeListController

@synthesize recipes;
@synthesize tagList;
@synthesize search;
DBRestClient *restClient;
NSMutableDictionary *dropboxDictionary;
NSInteger fileCount = 0;
NSInteger totalFiles = 0;

NSSortDescriptor *alphaSort;
NSSortDescriptor *ratingsSort;
NSSortDescriptor *tagSort;
RMSortMode sortMode = RMAlphaSort;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    UIBarButtonItem *sync = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didPressSync)];
    UIBarButtonItem *alpha = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"alpha.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alphaSort)];
    UIBarButtonItem *tags = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tag.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tagSort)];
    UIBarButtonItem *ratings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"starhighlighted.png"] style:UIBarButtonItemStylePlain target:self action:@selector(ratingsSort)];
    
    [super viewDidLoad];

    
    alphaSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    ratingsSort = [NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO];
    tagSort = [NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:tags, ratings, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:sync, alpha, nil];
    dropboxDictionary = [[NSMutableDictionary alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadRecipes];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    if ([segue.identifier isEqualToString:@"OpenRecipe"]) {
        NSInteger row = [[self.tableView indexPathForCell:sender] row];
        RecipeController *rc = segue.destinationViewController;
        [rc setRecipe:[recipes objectAtIndex:row]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark manage data source

- (void)reloadRecipes {
    switch (sortMode) {
        case RMAlphaSort:
            [self setRecipes:[self getRecipes:[NSArray arrayWithObject:alphaSort]]];
            break;
        case RMTagSort:
            [self setTagList:[self getTags:[NSArray arrayWithObject:tagSort]]];
            break;
        case RMRatingsSort:
            [self setRecipes:[self getRecipes:[NSArray arrayWithObjects:ratingsSort, alphaSort, nil]]];
            break;
    }
    
    [self setTitle:[NSString stringWithFormat:@"%d recipes", [recipes count]]];
    [self.tableView reloadData];
}

- (NSArray *)getRecipes:(NSArray *)sortDescriptors {
    if (search.text.length > 1) {
        NSArray *ingredientSearch = [Recipe searchIngredients:search.text];
        NSArray *tagSearch = [Recipe searchTags:search.text];
        return [[[NSSet setWithArray:ingredientSearch] setByAddingObjectsFromArray:tagSearch] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return [[Recipe getList] sortedArrayUsingDescriptors:sortDescriptors];
    }
}

- (NSArray *)getTags:(NSArray *)sortDescriptors {
    if (search.text.length > 1) {
        return [Tag search:search.text];
    } else {
        return [Tag getList];
    }
}

#pragma mark dropbox

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)didPressSync {
    if ([[DBSession sharedSession] isLinked]) {
        [self syncRecipes];
    } else {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)syncRecipes {
    NSString *cursor = [[NSUserDefaults standardUserDefaults] stringForKey:@"cursor"];
    if (cursor == nil) cursor = @"";

    [self setTitle:@"Syncing..."];
    [[self restClient] loadDelta:cursor];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"\t%@", file.filename);
        }
    }
}

-(void)restClient:(DBRestClient *)client loadedDeltaEntries:(NSArray *)entries reset:(BOOL)shouldReset cursor:(NSString *)cursor hasMore:(BOOL)hasMore {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"recipes"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    fileCount = totalFiles = [entries count];
    
    if (totalFiles > 0) {
        [self setTitle:[NSString stringWithFormat:@"Sync: 0 / %d", totalFiles]];
    } else {
        [self reloadRecipes];
    }
    
    for (DBDeltaEntry *file in entries) {
        if(!file.metadata.isDirectory) {
            NSString *filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:file.lowercasePath];
            [dropboxDictionary setObject:file forKey:filename];
            [[self restClient] loadFile:file.lowercasePath intoPath:filename];
        } else {
            fileCount--;
            totalFiles--;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:cursor forKey:@"cursor"];
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    NSError *error;
    DBDeltaEntry *file = [dropboxDictionary objectForKey:destPath];
    
    if ([[file.lowercasePath pathComponents] containsObject:@"recipes"]) {
        NSString *md = [NSString stringWithContentsOfFile:destPath encoding:NSUTF8StringEncoding error:&error];
        Recipe *r = [Recipe findOrCreate:file.lowercasePath bySource:@"dropbox"];
        [r update:md];
    }

    fileCount--;
    [self setTitle:[NSString stringWithFormat:@"Sync: %d / %d", totalFiles - fileCount, totalFiles]];
    if (fileCount == 0) {
        [[Recipe managedObjectContext] save:&error];
        [self reloadRecipes];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (sortMode == RMTagSort) ? [tagList count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (sortMode == RMTagSort) ? [[[tagList objectAtIndex:section] recipes] count] : [recipes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (sortMode == RMTagSort) ? [(Tag *)[tagList objectAtIndex:section] tag] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Recipe *recipe;
    UILabel *recipeName = (UILabel *)[cell viewWithTag:100];
    EDStarRating *rating = (EDStarRating *)[cell viewWithTag:200];
    UILabel *tagList = (UILabel *)[cell viewWithTag:300];
    
    if (sortMode == RMTagSort) {
        NSArray *sort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSPredicate *p = [NSPredicate predicateWithFormat:@"deleted = %d", NO];
        Tag *tag = [[self tagList] objectAtIndex:indexPath.section];
        NSSet *recipeList = [tag recipes];
        NSArray *r = [[recipeList filteredSetUsingPredicate:p] sortedArrayUsingDescriptors:sort];
        recipe = [r objectAtIndex:indexPath.row];
    } else {
        recipe = [recipes objectAtIndex:indexPath.row];
    }
    
    rating.starImage = [UIImage imageNamed:@"star.png"];
    rating.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    rating.maxRating = 5.0;
    rating.delegate = self;
    rating.editable=NO;
    rating.displayMode=EDStarRatingDisplayFull;
    rating.rating = [recipe.rating floatValue];

    [recipeName setText:[recipe name]];
    [tagList setText:[recipe tagList]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"OpenRecipe" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark search delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self reloadRecipes];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
    [self reloadRecipes];
    [searchBar resignFirstResponder];
}

#pragma mark nav buttons

- (void)ratingsSort {
    sortMode = RMRatingsSort;
    [self reloadRecipes];
}

- (void)alphaSort {
    sortMode = RMAlphaSort;
    [self reloadRecipes];
}

- (void)tagSort {
    sortMode = RMTagSort;
    [self reloadRecipes];
}

@end
