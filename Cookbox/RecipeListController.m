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

@interface RecipeListController ()

@end

@implementation RecipeListController

@synthesize recipes;
DBRestClient *restClient;
NSMutableDictionary *dropboxDictionary;
NSInteger fileCount = 0;
NSInteger totalFiles = 0;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *sync = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(didPressLink)];
 
    self.navigationItem.leftBarButtonItem = sync;
    dropboxDictionary = [[NSMutableDictionary alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [self reloadRecipes];
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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

#pragma mark dropbox

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)didPressLink {
    if ([[DBSession sharedSession] isLinked]) {
        [self syncRecipes];
    } else {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)reloadRecipes {
    [self setRecipes:[Recipe getList]];
    [self setTitle:[NSString stringWithFormat:@"%d recipes", [recipes count]]];
}

- (void)syncRecipes {
    NSString *cursor = [[NSUserDefaults standardUserDefaults] stringForKey:@"cursor"];
    [self setTitle:@"Syncing recipes..."];
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

-(void)restClient:(DBRestClient *)client loadedDeltaEntries:(NSArray *)entries reset:(BOOL)shouldReset cursor:(NSString *)cursor hasMore:(BOOL)hasMore{
    fileCount = totalFiles = [entries count];
    [self setTitle:[NSString stringWithFormat:@"Syncing recipes (0 / %d)", totalFiles]];

    for (DBDeltaEntry *file in entries) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file.lowercasePath];
        if(!file.metadata.isDirectory){
            [dropboxDictionary setObject:file forKey:path];
            [[self restClient] loadFile:file.lowercasePath intoPath:path];
        }
    }
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    NSError *error;
    NSString *md = [NSString stringWithContentsOfFile:destPath encoding:NSStringEncodingConversionAllowLossy error:&error];
    DBDeltaEntry *file = [dropboxDictionary objectForKey:destPath];
    Recipe *r = [Recipe findOrCreate:file.lowercasePath bySource:@"dropbox"];
    
    [r update:md];
    [r save];

    fileCount--;
    [self setTitle:[NSString stringWithFormat:@"Syncing recipes (%d / %d)", totalFiles - fileCount, totalFiles]];
    if (fileCount == 0) {
        [self reloadRecipes];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setText:[[recipes objectAtIndex:indexPath.row] name]];
    
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

@end
