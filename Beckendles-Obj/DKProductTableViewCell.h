//
//  DKProductTableViewCell.h
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKProduct.h"

@interface DKProductTableViewCell : UITableViewCell

@property(nonatomic,strong) UIImage *image;
- (void)configureWith:(DKProduct *)product;

@end
