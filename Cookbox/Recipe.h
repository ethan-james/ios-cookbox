//
//  Recipe.h
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <DropboxSDK/DropboxSDK.h>

@interface Recipe : NSManagedObject <DBRestClientDelegate>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * prep_time;
@property (nonatomic, retain) NSString * cook_time;
@property (nonatomic, retain) NSString * directions;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * markdown;
@property (nonatomic, retain) NSSet *ingredients;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) DBRestClient *restClient;

@end

@interface Recipe (CoreDataGeneratedAccessors)

- (void)addIngredientsObject:(NSManagedObject *)value;
- (void)removeIngredientsObject:(NSManagedObject *)value;
- (void)addIngredients:(NSSet *)values;
- (void)removeIngredients:(NSSet *)values;
- (void)update:(NSString *)markdown;
- (NSError *)save;
- (NSString *)tagList;
- (NSString *)asHTML;
- (void)changeRating:(NSNumber *)r;

+ (NSManagedObjectContext *)managedObjectContext;
+ (Recipe *)findOrCreate:(NSString *)identifier bySource:(NSString *)source;
+ (NSArray *)getList;
+ (NSArray *)searchIngredients:(NSString *)s;
+ (NSArray *)searchTags:(NSString *)s;

@end
