//
//  RecipeSource.h
//  Cookbox
//
//  Created by Ethan James on 1/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Recipe.h"


@interface RecipeSource : NSManagedObject

@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) Recipe *recipe;

@end
