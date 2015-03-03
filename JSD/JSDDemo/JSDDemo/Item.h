

#import <Foundation/Foundation.h>
#import "Constant.h"

@interface Item : NSObject<NSCopying>

@property (nonatomic, strong) NSString *itemID;
@property (nonatomic, strong) NSString *itemName;

@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger column;
@property (nonatomic) NSString *itemSizeTypes;

@property (nonatomic) ItemSizeType currentSizeType;

@property (nonatomic) NSArray *imageNames;

@end
