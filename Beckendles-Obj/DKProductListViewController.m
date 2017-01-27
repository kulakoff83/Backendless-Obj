//
//  DKProductListViewController.m
//  Beckendles-Obj
//
//  Created by Dmitry Kulakov on 25.01.17.
//  Copyright © 2017 kulakoff. All rights reserved.
//

#import "DKProductListViewController.h"
#import "DKProductTableViewCell.h"
#import "Product.h"
#import "DKProductDetailsViewController.h"
#import <Backendless.h>
#import "AppDelegate.h"

static NSString *ProductsCellIdentifier = @"ProductCell";
static NSString *ProductsDetailsSegueIdentifier = @"ProductDetailsSegue";
static NSInteger pageSize = 10;

@interface DKProductListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *products;
@property (nonatomic,getter=isLoad) BOOL load;
@property (strong,nonatomic) BackendlessCollection *productBackendlessCollection;

@end

@implementation DKProductListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - Request

- (void)requestProducts {
    __weak typeof(self) weakSelf = self;
    BackendlessDataQuery *query = [BackendlessDataQuery query];
    query.queryOptions.pageSize = [NSNumber numberWithInt:(unsigned)pageSize];
    [backendless.persistenceService find:[Product class] dataQuery:query response:^(BackendlessCollection * objectBackendlessCollection) {
        weakSelf.productBackendlessCollection = objectBackendlessCollection;
        weakSelf.products = [[NSMutableArray alloc] initWithArray:[objectBackendlessCollection getCurrentPage]];
        weakSelf.tableView.tableFooterView.hidden = NO;
        [weakSelf.tableView reloadData];
    } error:^(Fault * fault) {
        NSLog(@"%@", fault);
    }];
}
     
- (void)requestNextProducts {
    __weak typeof(self) weakSelf = self;
    [self.productBackendlessCollection nextPageAsync:^(BackendlessCollection * objectBackendlessCollection) {
        weakSelf.productBackendlessCollection = objectBackendlessCollection;
        [weakSelf.products addObjectsFromArray:[objectBackendlessCollection getCurrentPage]];
        [weakSelf.tableView reloadData];
        if (weakSelf.productBackendlessCollection.totalObjects.intValue <= weakSelf.products.count) {
            weakSelf.tableView.tableFooterView.hidden = YES;
            weakSelf.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    } error:^(Fault * fault) {
        NSLog(@"%@", fault);
    }];
}

#pragma mark - TableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DKProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductsCellIdentifier forIndexPath:indexPath];
    Product *product = self.products[indexPath.row];
    [cell configureWith:product];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Product *product = self.products[indexPath.row];
    DKProductTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    product.image = cell.image;
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
    [self requestNextProducts];
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:ProductsDetailsSegueIdentifier]) {
         DKProductDetailsViewController *productDetailsVC = segue.destinationViewController;
         productDetailsVC.product = (Product*)sender;
     }
 }

@end
