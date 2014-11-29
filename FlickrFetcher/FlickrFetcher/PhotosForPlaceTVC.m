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
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    if (title)
    {
        cell.textLabel.text = title;
        if (description)
        {
            cell.detailTextLabel.text = description;
            return cell;
        }
        
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    if (description)
    {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
                                   
                                   [self.tableView reloadData];
                               }
                               else
                               {
                                 NSLog(@"error loading photos for place: %@", error);
                               }
                               
                           }];
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

@end
