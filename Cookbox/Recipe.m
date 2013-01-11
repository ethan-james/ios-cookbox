//
//  Recipe.m
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import "Recipe.h"
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

#pragma mark Dropbox

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)dest from:(NSString *)src {
    
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

# pragma mark CRUD helpers

- (void)update:(NSString *)markdown {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"# (.+) #" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange range = NSMakeRange(0, [markdown length]);
    NSTextCheckingResult *match = [regex firstMatchInString:markdown options:NSMatchingWithoutAnchoringBounds range:range];
    NSRange nameRange = [match rangeAtIndex:1];
    NSString *name = [markdown substringWithRange:nameRange];
    
    [self setName:name];
    [self setMarkdown:markdown];
}

- (NSError *)save {
    NSError *error;
    [[self managedObjectContext] save:&error];

    if ([[DBSession sharedSession] isLinked]) {
        NSData *data = [[self markdown] dataUsingEncoding:NSStringEncodingConversionExternalRepresentation];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filename = [[self slug] stringByAppendingPathExtension:@"mdown"];
        NSString *dir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"recipes"];
        NSString *path = [dir stringByAppendingPathComponent:filename];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:&error];
        }

        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        [[self restClient] uploadFile:filename toPath:@"/recipes" fromPath:path];
    }
    
    return error;
}

- (NSString *)asHTML {
    return [GHMarkdownParser flavoredHTMLStringFromMarkdownString:[self markdown]];
}

- (NSString *)slug {
    NSError *error;
    NSRange r = NSMakeRange(0, self.name.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-z0-9]+" options:0 error:&error];
    
    return [regex stringByReplacingMatchesInString:[self.name lowercaseString] options:0 range:r withTemplate:@"-"];
}

@end
