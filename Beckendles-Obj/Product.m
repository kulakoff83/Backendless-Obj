//
//  DKProduct.m
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import "Product.h"


@implementation Product

- (NSString *)description {
    NSString *descriptionString = self.productDescription;
    return descriptionString ? descriptionString : @"";
    
}

-(void)setDescription:(NSMutableString *)description {
    self.productDescription = description;
}

@end
