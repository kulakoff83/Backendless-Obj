//
//  DKProduct.h
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface DKProduct : RLMObject

@property NSNumber<RLMInt> *price;
@property NSString *name;
@property NSString *productDescription;
@property NSString *imageURL;
@property NSData *imageData;
@property NSString *objectID;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (void)mapWithDictionary:(NSDictionary*)dictionary;

@end
