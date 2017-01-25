//
//  DKProductListViewController.m
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import "DKProductListViewController.h"
#import "DKAPIManager.h"
#import "DKProductTableViewCell.h"
#import "DKProduct.h"
#import "DKProductDetailsViewController.h"
@import Realm;

static NSString *ProductsCellIdentifier = @"ProductCell";
static NSString *ProductsDetailsSegueIdentifier = @"ProductDetailsSegue";

@interface DKProductListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSString *nextPageURL;
@property (strong,nonatomic) RLMResults *products;
@property (strong, nonatomic) RLMNotificationToken *notificationToken;
@property (nonatomic,getter=isLoad) BOOL load;

@end

@implementation DKProductListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureRealmNotification];
    [self requestProducts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (![self isLoad]) {
        [self configureTableView];
        self.load = YES;
    }
}

- (void)dealloc {
    [self.notificationToken stop];
}

#pragma mark - Request

- (void)requestProducts {
    __weak typeof(self) weakSelf = self;
    [[DKAPIManager sharedInstance] sendProductsRequest:self.nextPageURL succesBlock:^(NSString *nextURL) {
        weakSelf.nextPageURL = nextURL;
    } errorBlock:^(NSError * error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - Realm Notification Token

- (void)configureRealmNotification {
    self.products = [DKProduct allObjects];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjects:self.products];
    [realm commitWriteTransaction];
    __weak typeof(self) weakSelf = self;
    self.notificationToken = [self.products addNotificationBlock:^(RLMResults<DKProduct *> *results, RLMCollectionChange *changes, NSError *error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }
        UITableView *tableView = weakSelf.tableView;
        // Initial run of the query will pass nil for the change information
        if (!changes) {
            [tableView reloadData];
            return;
        }
        // Query results have changed, so apply them to the UITableView
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[changes deletionsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView insertRowsAtIndexPaths:[changes insertionsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadRowsAtIndexPaths:[changes modificationsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        if (![weakSelf.nextPageURL isKindOfClass:[NSNull class]]) {
            tableView.tableFooterView.hidden = NO;
        } else {
            tableView.tableFooterView.hidden = YES;
            tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        }
    }];
}

#pragma mark - TableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DKProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductsCellIdentifier forIndexPath:indexPath];
    DKProduct *product = self.products[indexPath.row];
    [cell configureWith:product];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DKProduct *product = self.products[indexPath.row];
    DKProductTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    NSData *data = UIImageJPEGRepresentation(cell.image, 1.0);
    product.imageData = data;
    [realm commitWriteTransaction];
    [self performSegueWithIdentifier:ProductsDetailsSegueIdentifier sender:product];
}

#pragma mark - Configure

- (void)configureTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"DKProductTableViewCell" bundle:nil] forCellReuseIdentifier:ProductsCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 120;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self configureFooterView];
}

- (void)configureFooterView {
    UIView *loadMoreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.tableView.tableFooterView = loadMoreView;
    UIButton *loadMoreButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    loadMoreButton.backgroundColor = [UIColor whiteColor];
    [loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
    [loadMoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loadMoreButton addTarget:self action:@selector(loadMoreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    loadMoreButton.layer.cornerRadius = 10;
    loadMoreButton.layer.borderWidth = 1;
    loadMoreButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [loadMoreView addSubview:loadMoreButton];
    loadMoreButton.center = loadMoreView.center;
    self.tableView.tableFooterView.hidden = YES;
}

#pragma mark - Actions

- (void)loadMoreButtonPressed {
    [self requestProducts];
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:ProductsDetailsSegueIdentifier]) {
         DKProductDetailsViewController *productDetailsVC = segue.destinationViewController;
         productDetailsVC.product = (DKProduct*)sender;
     }
 }

@end
