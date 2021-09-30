//
//  CategoryVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "CategoryVC.h"
#import "CategoryCollectionViewCell.h"
#import "SuperViewController.h"

@interface CategoryVC () <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSArray *categoryNames;
    NSArray *categoryIcons;
}
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;

@end

@implementation CategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    categoryNames = @[@"Auto Detailing", @"Carpentry", @"Electronics", @"Masonry", @"Cleaning", @"Electrical", @"Metal Works", @"Plumbing", @"Hot Jobs", @"Moving and Shipping", @"Daycare", @"Pet Care", @"Tutoring", @"Landscaping", @"Garbage Removal", @"Auto Mechanic", @"Furniture Assembly", @"Other Jobs"];
    categoryIcons = @[@"ic_category_automotive.png", @"ic_category_carpentry.png", @"ic_category_electronics.png", @"ic_category_masonry.png", @"ic_category_cleaning.png", @"ic_category_electrical.png", @"ic_category_metal_works.png", @"ic_category_plumbing.png", @"ic_category_hot_jobs.png", @"ic_category_moving_shipping.png", @"ic_category_daycare.png", @"ic_category_petcare.png", @"ic_category_tutoring.png", @"ic_category_landscaping.png", @"ic_category_garbage_removal.png", @"ic_category_auto_mechanic.png", @"ic_category_furniture_assembly.png", @"ic_category_other_jobs.png"];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    _lblCategory.text = [defaults objectForKey:CURRENT_CATEGORY];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return categoryNames.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionViewCell" forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    if (row < categoryNames.count) {
        UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
        UILabel *lblCategory = (UILabel *)[cell viewWithTag:2];
        lblCategory.text = categoryNames[row];
        imgCategory.image = [UIImage imageNamed:categoryIcons[row]];
    }
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:categoryNames[indexPath.row] forKey:CURRENT_CATEGORY];
    [self onBack:nil];
}

- (CGSize) collectionView:(UICollectionView *) collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    int nWidth = (CGRectGetWidth(collectionView.frame) - 30 ) / 3;
    int nHeight = nWidth + 30;
    return CGSizeMake(nWidth, nHeight);
}

@end
