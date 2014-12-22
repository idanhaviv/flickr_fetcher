//
//  UserHistoryTVCTableViewController.m
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 12/13/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import "UserHistoryTVC.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface UserHistoryTVC ()

@property (nonatomic) NSArray *photosForUser;
@end

@implementation UserHistoryTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.photosForUser = [userDefaults arrayForKey:@"photoList"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photosForUser count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUseCell" forIndexPath:indexPath];
    
    NSString *title = [self.photosForUser[indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [self.photosForUser[indexPath.row] objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    if (title)
    {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = description;
    }
    else if (description)
    {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
    }
    else
    {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PhotosForUserSegue"])
    {
        PhotoViewController *photoVC = [segue destinationViewController];
        [photoVC setPhotoDetails:[self getPhotoDetailsForCell:sender]];
    }
}

- (NSDictionary *)getPhotoDetailsForCell:(UITableViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *photo = self.photosForUser[cellIndexPath.row];
    return photo;
}

@end
