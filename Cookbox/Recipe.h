//
//  Recipe.h
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recipe : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * prep_time;
@property (nonatomic, retain) NSString * cook_time;
@property (nonatomic, retain) NSString * directions;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * markdown;
@property (nonatomic, retain) NSSet *ingredients;
@end

@interface Recipe (CoreDataGeneratedAccessors)

- (void)addIngredientsObject:(NSManagedObject *)value;
- (void)removeIngredientsObject:(NSManagedObject *)value;
- (void)addIngredients:(NSSet *)values;
- (void)removeIngredients:(NSSet *)values;
- (void)update:(NSString *)markdown;
- (NSError *)save;

+ (Recipe *)findOrCreate:(NSString *)identifier bySource:(NSString *)source;
+ (NSArray *)getList;

@end
