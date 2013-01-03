//
//  Ingredient.h
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipe;

@interface Ingredient : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * canonical;
@property (nonatomic, retain) Recipe *recipe;
@property (nonatomic, retain) NSNumber * ordinal;

@end
