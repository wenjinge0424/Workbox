//
//  EditProfileVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "EditProfileVC.h"
#import "ProfileVideoCollectionViewCell.h"

@interface EditProfileVC ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UIButton *btnEdit;
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UITextField *categoryTF;
    __weak IBOutlet UIView *categoryV;
    __weak IBOutlet UILabel *lblDistance;
    __weak IBOutlet UICollectionView *videoCV;
    __weak IBOutlet UITextField *tfName;
    __weak IBOutlet UITextField *tfLocation;
}

@end

@implementation EditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileVideoCollectionViewCell" forIndexPath:indexPath];
    UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblCategory = (UILabel *)[cell viewWithTag:2];
    UIButton *btnDelete = (UIButton *)[cell viewWithTag:3];
    [btnDelete setHidden:NO];
 
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize) collectionView:(UICollectionView *) collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    int nWidth = (CGRectGetWidth(collectionView.frame) - 15 ) / 3;
    int nHeight = nWidth * 1.3;
    return CGSizeMake(nWidth, nHeight);
}

- (IBAction)onEdit:(id)sender {
    // save
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCategory:(id)sender {
}
- (IBAction)onDistance:(id)sender {
}
- (IBAction)onAdd:(id)sender {
}
- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTapStarView:(id)sender {
}



@end
