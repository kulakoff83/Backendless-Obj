//
//  DKProductTableViewCell.m
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import "DKProductTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface DKProductTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;

@end

@implementation DKProductTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.productNameLabel.text = nil;
    self.productDescriptionLabel.text = nil;
    self.productImageView.image = nil;
}

- (void)configureWith:(DKProduct *)product {
    self.productNameLabel.text = product.name;
    self.productDescriptionLabel.text = product.productDescription;
    NSURL *url = [NSURL URLWithString:product.imageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak DKProductTableViewCell *weakCell = self;
    [self.productImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakCell.productImageView.image = image;
        weakCell.image = image;
        [weakCell setNeedsLayout];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        //
    }];
}

@end
