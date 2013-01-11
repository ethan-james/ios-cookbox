//
//  RecipeSource.m
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import "RecipeSource.h"
#import "AppDelegate.h"

@implementation RecipeSource

@dynamic source;
@dynamic identifier;
@dynamic recipe;

NSManagedObjectContext *_managedObjectContext;

+ (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        AppDelegate *d = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [d managedObjectContext];
    }
    
    return _managedObjectContext;
}

#pragma mark CRUD helpers

+ (RecipeSource *)new:(NSString *)identifier fromSource:(NSString *)source {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *r = [NSEntityDescription entityForName:@"RecipeSource" inManagedObjectContext:moc];
    RecipeSource *rs = [[RecipeSource alloc] initWithEntity:r insertIntoManagedObjectContext:moc];
    
    [rs setSource:source];
    [rs setIdentifier:identifier];
    
    return rs;
}

@end
