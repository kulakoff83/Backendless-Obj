//
//  DKProduct.m
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import "DKProduct.h"

static NSString *ObjectIDKey = @"objectID";

@implementation DKProduct

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        self.objectID = dictionary[@"objectId"];
        [self mapWithDictionary:dictionary];
    }
    return self;
}

- (void)mapWithDictionary:(NSDictionary*)dictionary {
    self.name = dictionary[@"productName"];
    self.productDescription = dictionary[@"description"];
    self.imageURL = dictionary[@"imageURL"];
    self.price = dictionary[@"price"];
}

+ (NSString *)primaryKey {
    return ObjectIDKey;
}

+ (NSDictionary *)defaultPropertyValues {
    return @{ObjectIDKey : @"0"};
}

@end
