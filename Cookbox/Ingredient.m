//
//  Ingredient.m
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import "Ingredient.h"
#import "Recipe.h"
#import "AppDelegate.h"

@implementation Ingredient

@dynamic text;
@dynamic canonical;
@dynamic recipe;
@dynamic ordinal;


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

+ (Ingredient *)new:(NSString *)text forRecipe:(Recipe *)recipe {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *i = [NSEntityDescription entityForName:@"Ingredient" inManagedObjectContext:moc];
    NSNumber *ordinal = [NSNumber numberWithInt:[recipe.ingredients count] + 1];
    Ingredient *ingredient = [[Ingredient alloc] initWithEntity:i insertIntoManagedObjectContext:moc];

    [ingredient setText:text];
    [ingredient setRecipe:recipe];
    [ingredient setOrdinal:ordinal];
    
    return ingredient;
}

@end
