//
//  Tag.m
//  Cookbox
//
//  Created by Ethan James on 1/22/13.
//
//

#import "Tag.h"
#import "Recipe.h"
#import "AppDelegate.h"


@implementation Tag

@dynamic tag;
@dynamic recipes;

NSManagedObjectContext *_managedObjectContext;

+ (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        AppDelegate *d = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [d managedObjectContext];
    }
    
    return _managedObjectContext;
}

+ (NSArray *)getList {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *t = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc];
    NSArray *sort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]];
    NSError *error;
    
    [request setEntity:t];
    [request setSortDescriptors:sort];
    
    return [moc executeFetchRequest:request error:&error];
}

+ (NSArray *)search:(NSString *)text {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *tag = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc];
    NSArray *sort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"tag CONTAINS[c] %@", text];
    NSError *error;
    
    [request setEntity:tag];
    [request setPredicate:searchPredicate];
    [request setSortDescriptors:sort];
    
    return [moc executeFetchRequest:request error:&error];
}

+ (Tag *)findOrCreate:(NSString *)text {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *t = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag = %@", text];
    NSError *error;
    NSArray *results;
    
    [request setEntity:t];
    [request setPredicate:predicate];
    
    results = [moc executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        return [results lastObject];
    } else {
        Tag *tag = [[Tag alloc] initWithEntity:t insertIntoManagedObjectContext:moc];
        [tag setTag:text];
        [moc save:&error];
        return tag;
    }
}

- (NSError *)save {
    NSError *error;
    [[self managedObjectContext] save:&error];
    return error;
}

@end
