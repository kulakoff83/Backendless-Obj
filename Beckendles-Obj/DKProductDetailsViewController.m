//
//  DKProductDetailsViewController.m
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import "DKProductDetailsViewController.h"

@interface DKProductDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;

@end

@implementation DKProductDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)configureElements {
    self.productNameLabel.text = self.product.productName;
    self.productPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.product.price.floatValue];
    self.productImageView.image = self.product.image;
    self.productDescriptionTextView.text = self.product.productDescription;
}

@end
