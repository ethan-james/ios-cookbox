//
//  Recipe.m
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import "Recipe.h"
#import "Ingredient.h"
#import "AppDelegate.h"
#import "RecipeSource.h"
#import <GHMarkdownParser/GHMarkdownParser/GHMarkdownParser.h>

@implementation Recipe

@dynamic name;
@dynamic prep_time;
@dynamic cook_time;
@dynamic directions;
@dynamic url;
@dynamic quantity;
@dynamic comments;
@dynamic markdown;
@dynamic ingredients;

@synthesize restClient;

- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

#pragma mark Dropbox

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)dest from:(NSString *)src {
    NSLog(@"%@ uploaded to dropbox", dest);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [[self restClient] uploadFile:metadata.filename toPath:@"/recipes"  withParentRev:metadata.rev fromPath:[self localPath]];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    if (error.code == 404) {
        [[self restClient] uploadFile:[self filename] toPath:@"/recipes"  withParentRev:nil fromPath:[self localPath]];
    }
}

#pragma mark core data

NSManagedObjectContext *_managedObjectContext;

+ (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        AppDelegate *d = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [d managedObjectContext];
    }

    return _managedObjectContext;
}

#pragma mark static fetch helpers

+ (Recipe *)new {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *r = [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:moc];
    return [[Recipe alloc] initWithEntity:r insertIntoManagedObjectContext:moc];
}

+ (Recipe *)findOrCreate:(NSString *)identifier bySource:(NSString *)source {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *rs = [NSEntityDescription entityForName:@"RecipeSource" inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@ AND source = %@", identifier, source];
    NSError *error;
    NSArray *results;
    
    [request setEntity:rs];
    [request setPredicate:predicate];
    
    results = [moc executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        return [[results lastObject] recipe];
    } else {
        NSEntityDescription *r = [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:moc];
        Recipe *recipe = [[Recipe alloc] initWithEntity:r insertIntoManagedObjectContext:moc];
        RecipeSource *s = [[RecipeSource alloc] initWithEntity:rs insertIntoManagedObjectContext:moc];
        
        [s setIdentifier:identifier];
        [s setSource:source];
        [s setRecipe:recipe];
        
        [moc save:&error];
        return recipe;
    }
}

+ (NSArray *)getList {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *r = [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:moc];
    NSArray *sort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error;
    
    [request setEntity:r];
    [request setSortDescriptors:sort];
    
    return [moc executeFetchRequest:request error:&error];
}

+ (NSArray *)searchIngredients:(NSString *)s {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *i = [NSEntityDescription entityForName:@"Ingredient" inManagedObjectContext:moc];
    NSArray *sort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"text CONTAINS %@", s];
    NSError *error;
    NSArray *ingredients;
    NSMutableSet *recipes = [[NSMutableSet alloc] init];

    [request setEntity:i];
    [request setPredicate:searchPredicate];
    
    ingredients = [moc executeFetchRequest:request error:&error];
    for (Ingredient *ingredient in ingredients) {
        [recipes addObject:ingredient.recipe];
    }

    return [recipes sortedArrayUsingDescriptors:sort];
}

# pragma mark CRUD helpers

- (void)update:(NSString *)markdown {
    NSError *error;
    NSString *ingredients;
    NSArray *ingredientMatches;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"# (.+) #" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange range = NSMakeRange(0, [markdown length]);
    NSTextCheckingResult *match = [regex firstMatchInString:markdown options:NSMatchingWithoutAnchoringBounds range:range];
    NSRange nameRange = [match rangeAtIndex:1];
    NSRegularExpression *ingredientsRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\* (.+)$" options:NSRegularExpressionAnchorsMatchLines error:&error];
    NSString *name = [markdown substringWithRange:nameRange];
    
    [self setName:name];
    [self setMarkdown:markdown];
    [self clearIngredients];
    
    ingredients = [self ingredientsBlock];
    ingredientMatches = [ingredientsRegex matchesInString:ingredients options:0 range:NSMakeRange(0, [ingredients length])];
    
    for (NSTextCheckingResult *line in ingredientMatches) {
        [self addIngredientsObject:[Ingredient new:[ingredients substringWithRange:[line rangeAtIndex:1]] forRecipe:self]];
    }
}

- (NSError *)save {
    NSError *error;
    [[self managedObjectContext] save:&error];

    if ([[DBSession sharedSession] isLinked]) {
        NSData *data = [[self markdown] dataUsingEncoding:NSUTF8StringEncoding];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *recipeDirectory = [[self appDelegate] recipeDirectory];
        
        if (![fileManager fileExistsAtPath:recipeDirectory]) {
            [fileManager createDirectoryAtPath:recipeDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        }

        [fileManager createFileAtPath:[self localPath] contents:data attributes:nil];
        [[self restClient] loadMetadata:[@"/recipes" stringByAppendingPathComponent:[self filename]]];
    }
    
    return error;
}

- (void)clearIngredients {
    for (NSManagedObject *ingredient in [self ingredients]) {
        [[self managedObjectContext] deleteObject:ingredient];
    }
}

#pragma mark formatting helpers

- (NSString *)slug {
    NSError *error;
    NSRange r = NSMakeRange(0, self.name.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-z0-9]+" options:0 error:&error];
    
    return [regex stringByReplacingMatchesInString:[self.name lowercaseString] options:0 range:r withTemplate:@"-"];
}

- (NSString *)asHTML {
    return [GHMarkdownParser flavoredHTMLStringFromMarkdownString:[self markdown]];
}

- (NSString *)ingredientsBlock {
    NSError *error;
    NSString *markdown = [self markdown];
    NSRange range = NSMakeRange(0, [markdown length]);
    NSRegularExpression *ingredientsHeaderRegex = [NSRegularExpression regularExpressionWithPattern:@"\\*\\*Ingredients\\*\\*\\s+" options:NSRegularExpressionUseUnixLineSeparators error:&error];
    NSRange ingredientsHeader = [ingredientsHeaderRegex rangeOfFirstMatchInString:markdown options:NSRegularExpressionUseUnixLineSeparators range:range];
    NSRange ingredientsBlock = NSMakeRange(ingredientsHeader.location + ingredientsHeader.length, [markdown length] - ingredientsHeader.location - ingredientsHeader.length);
    NSRange ingredientsEnd = [markdown rangeOfString:@"\n\n" options:NSLiteralSearch range:ingredientsBlock];

    ingredientsBlock.length = ingredientsEnd.location - ingredientsBlock.location;
    return [markdown substringWithRange:ingredientsBlock];
}

- (NSString *)filename {
    return [[self slug] stringByAppendingPathExtension:@"mdown"];
}

- (NSString *)localPath {
    return [[[self appDelegate] recipeDirectory] stringByAppendingPathComponent:[self filename]];
}

@end
