//
//  APIManager.h
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(NSString*);
typedef void(^ErrorBlock)(NSError*);

@interface DKAPIManager : NSObject

+ (id)sharedInstance;
- (void)sendProductsRequest:(NSString*)urlString succesBlock:(SuccessBlock)succes errorBlock:(ErrorBlock)reject;

@end
