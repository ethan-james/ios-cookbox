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

- (NSError *)save {
    NSError *error;
    [[self managedObjectContext] save:&error];
    return error;
}

@end
