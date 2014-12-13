//
//  PhotosForPlaceTVC.m
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 11/29/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import "PhotosForPlaceTVC.h"
#import "FlickrFetcher.h"
#import "FlickrFetcherUtility.h"
#import "PhotoViewController.h"

@interface PhotosForPlaceTVC ()

@property (nonatomic) NSArray *photosForPlace;
@end

@implementation PhotosForPlaceTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [self loadPhotoListData:self.placeDetails];
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
    return [self.photosForPlace count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotosForPlaceCell" forIndexPath:indexPath];
    
    NSString *title = [self.photosForPlace[indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [self.photosForPlace[indexPath.row] objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    //Swift Switch case of String :(
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
    if ([[segue identifier] isEqualToString:@"PhotoSelectedSegue"])
    {
        PhotoViewController *photoVC = [segue destinationViewController];
        [photoVC setPhotoDetails:[self getPhotoDetailsForCell:sender]];
    }
}

- (NSDictionary *)getPhotoDetailsForCell:(UITableViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *photo = self.photosForPlace[cellIndexPath.row];
    return photo;
}

#pragma mark - helper methods

- (void)loadPhotoListData:(NSDictionary *)placeDetails
{
    NSURL *urlForPhotosInPlace = [FlickrFetcher URLforPhotosInPlace:[placeDetails objectForKey:FLICKR_PLACE_ID] maxResults:50];
    [FlickrFetcherUtility dictionaryForUrl:urlForPhotosInPlace
                           completionBlock:^(NSData *data, NSError *error) {
                               if (!error) {
                                   NSLog(@"photos for place loaded successfully");
                                   NSError *jsonError;
                                   NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                                          options:0
                                                                                            error:&jsonError];
                                   if (jsonError)
                                   {
                                       NSLog(@"NSJSONSerialization error @loadPhotoListData: %@", jsonError);
                                       return;
                                   }
                                   
                                   self.photosForPlace = [result valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self.tableView reloadData];
                                   });
                               }
                               else
                               {
                                   NSLog(@"error loading photos for place: %@", error);
                               }
                               
                           }];
}

@end
