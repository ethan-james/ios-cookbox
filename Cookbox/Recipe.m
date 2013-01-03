//
//  Recipe.m
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import "Recipe.h"
#import "AppDelegate.h"
#import "RecipeSOurce.h"


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
    [self setMarkdown:markdown];
}

- (NSError *)save {
    NSError *error;
    [[self managedObjectContext] save:&error];
    return error;
}

@end
