//
//  APIManager.m
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import "DKAPIManager.h"
#import "DKProduct.h"
#import "AppDelegate.h"

@import AFNetworking;
@import Realm;

@interface DKAPIManager()

@property(nonatomic,strong) AFURLSessionManager *manager;
@property(nonatomic,strong) NSString *requestURL;

@end

@implementation DKAPIManager

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)sendProductsRequest:(NSString*)urlString succesBlock:(SuccessBlock)succes errorBlock:(ErrorBlock)reject {
    if (self.manager) {
        [self.manager.operationQueue cancelAllOperations];
    }
    self.requestURL = urlString;
    if (!self.requestURL) {
        self.requestURL = @"https://api.backendless.com/v1/data/Product?pageSize=10&offset=0";
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"application-id": APP_ID,@"secret-key": SECRET_KEY };
    self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.requestURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLSessionDataTask *dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            reject(error);
        } else {
            [self writeProducts:responseObject[@"data"] errorBlock:^(NSError *error) {
                if (!error) {
                    //if ([responseObject[@"nextPage"] isEqualToString:@"<null>"]) {
                        //succes(nil);
                    //} else {
                        succes(responseObject[@"nextPage"]);
                    //}
                } else {
                    reject(error);
                }
            }];
            //NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
}

- (void)writeProducts:(NSArray*)objects errorBlock:(ErrorBlock)reject {
    RLMRealm *realm = [RLMRealm defaultRealm];
    @try {
        NSMutableArray *realmObjects = [NSMutableArray new];
        [realm beginWriteTransaction];
        realmObjects = [self mapProductsWithObjects:objects];
        [realm addOrUpdateObjectsFromArray:realmObjects];
        [realm commitWriteTransaction];
        //NSLog(@"%@", realmObjects);
        reject(nil);
    }
    @catch (NSError *error) {
        NSLog(@"exception");
        if ([realm inWriteTransaction]) {
            [realm cancelWriteTransaction];
        }
        reject(error);
    }
}

- (NSMutableArray*)mapProductsWithObjects:(NSArray*)objects {
    NSMutableArray *realmProducts = [NSMutableArray new];
    for (NSDictionary *object in objects) {
        DKProduct *product = [[DKProduct alloc] initWithDictionary:object];
        [realmProducts addObject:product];
    }
    return realmProducts;
}

@end
