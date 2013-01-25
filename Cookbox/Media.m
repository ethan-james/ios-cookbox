//
//  Media.m
//  Cookbox
//
//  Created by Ethan James on 1/23/13.
//
//

#import "Media.h"
#import "Recipe.h"
#import "AppDelegate.h"


@implementation Media

@dynamic url;
@dynamic recipe;
@dynamic created_at;

NSManagedObjectContext *_managedObjectContext;

+ (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        AppDelegate *d = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [d managedObjectContext];
    }
    
    return _managedObjectContext;
}

+ (Media *)new:(NSString *)url {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *m = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:moc];
    Media *media = [[Media alloc] initWithEntity:m insertIntoManagedObjectContext:moc];
    
    [media setUrl:url];
    
    return media;
}

+ (Media *)find:(NSString *)url forRecipe:(Recipe *)recipe {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *tag = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:moc];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"url = %@", url];
    NSError *error;
    NSArray *media;
    NSUInteger index;
    
    [request setEntity:tag];
    [request setPredicate:searchPredicate];
    
    media = [moc executeFetchRequest:request error:&error];
    index = [media indexOfObjectPassingTest:^BOOL(Media *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recipe isEqual:recipe];
    }];
    
    return index == NSNotFound ? nil : [media objectAtIndex:index];
}

- (NSError *)save {
    NSError *error;
    [[self managedObjectContext] save:&error];
    return error;
}

- (void)delete {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error;
    [moc deleteObject:self];
    [moc save:&error];
}

@end
