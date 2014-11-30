	//
//  FlickrFetcherTableViewController.m
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 9/7/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcherUtility.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "PhotosForPlaceTVC.h"
    
@interface TopPlacesTVC ()

@property (nonatomic) NSDictionary *topPlacesDictionary;
@property (nonatomic) NSDictionary *places;
@property (nonatomic) NSArray *sizesOfPlacesDictionary;
@property (nonatomic) NSArray *placesArray;

@end

@implementation TopPlacesTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self prepareDataForTableViewCells];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sizesOfPlacesDictionary count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.placesArray[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sizesOfPlacesDictionary[section] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    
    NSString *country = self.placesArray[indexPath.section];
    
    NSString *placeName = [[self.places objectForKey:country][indexPath.row] objectForKey:FLICKR_PLACE_NAME];
    
    NSArray *placeSeparated = [placeName componentsSeparatedByString:@","];
    
    if ([placeSeparated count] == 3)
    {
        cell.textLabel.text = placeSeparated[0];
        cell.detailTextLabel.text = placeSeparated[1];
    }
    else
    {
        cell.textLabel.text = placeSeparated[0];
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = self.placesArray[section];
    }
}

#pragma mark - helper methods

- (void)prepareDataForTableViewCells
{
    [FlickrFetcherUtility dictionaryForUrl:[FlickrFetcher URLforTopPlaces] completionBlock:^(NSData *data, NSError *error)
    {
        if (!error)
        {
            NSLog(@"Flickr Fetcher TopPlaces http request successful");
            NSError *jsonError;
            self.topPlacesDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0
                                                                         error:&jsonError];
            if (jsonError)
            {
                NSLog(@"NSJSONSerialization error: %@", jsonError);
                return;
            }
            
            NSArray *places = [self.topPlacesDictionary valueForKeyPath:FLICKR_RESULTS_PLACES];
            self.places = [FlickrFetcherUtility placesDictionary:places];
            self.places = [FlickrFetcherUtility sortPlaces:self.places];
            
            
            self.sizesOfPlacesDictionary = [FlickrFetcherUtility sizesOfDictionary:self.places];
            self.placesArray = [self.places allKeys];
            self.places = [FlickrFetcherUtility sortPlaces:self.places];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else
        {
            NSLog(@"Flickr Fetcher TopPlaces http request error: %@", error);
        }
    }];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PhotosForPlaceSegue"])
    {
        PhotosForPlaceTVC *photosForPlaceTVC = [segue destinationViewController];
        [photosForPlaceTVC loadPhotoListData:[self getPhotosDetailsForCell:sender]];
    }
    
}
         
- (NSDictionary *)getPhotosDetailsForCell:(UITableViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    UITableViewHeaderFooterView *headerView = [self.tableView headerViewForSection:cellIndexPath.section];
    NSArray *placesForSection = [self.places objectForKey:headerView.textLabel.text];
    NSDictionary *placeDetails = placesForSection[cellIndexPath.row];
    return placeDetails;
}

@end
