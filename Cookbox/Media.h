//
//  Media.h
//  Cookbox
//
//  Created by Ethan James on 1/23/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipe;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Recipe *recipe;
@property (nonatomic, retain) NSDate *created_at;

+ (Media *)new:(NSString *)url;

- (NSError *)save;

@end
