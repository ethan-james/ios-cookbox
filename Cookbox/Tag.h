//
//  Tag.h
//  Cookbox
//
//  Created by Ethan James on 1/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipe;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSSet *recipes;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addRecipesObject:(Recipe *)value;
- (void)removeRecipesObject:(Recipe *)value;
- (void)addRecipes:(NSSet *)values;
- (void)removeRecipes:(NSSet *)values;
- (NSError *)save;

+ (NSArray *)getList;
+ (Tag *)findOrCreate:(NSString *)text;
+ (NSArray *)search:(NSString *)text;

@end
