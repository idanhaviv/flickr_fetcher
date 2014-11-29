//
//  FlickrFetcherTableViewController.m
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 9/7/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import "FlickrFetcherTableViewController.h"
#import "FlickrFetcherUtility.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface FlickrFetcherTableViewController ()

@property (nonatomic) NSDictionary *topPlacesDictionary;
@property (nonatomic) NSDictionary *places;
@property (nonatomic) NSArray *sizesOfPlacesDictionary;
@property (nonatomic) NSArray *placesArray;

@end

@implementation FlickrFetcherTableViewController

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
    
    NSString *placeInCountry = [self.places objectForKey:country][indexPath.row];
    
    NSArray *placeSeparated = [placeInCountry componentsSeparatedByString:@","];
    
    cell.textLabel.text = placeSeparated[0];
    
    cell.detailTextLabel.text = placeSeparated[1];
    
    return cell;
}

#pragma mark - helper methods

- (void)prepareDataForTableViewCells
{
    self.topPlacesDictionary = [FlickrFetcherUtility dictionaryForTopPlaces];
    NSArray *places = [self.topPlacesDictionary valueForKeyPath:FLICKR_RESULTS_PLACES];
    self.places = [FlickrFetcherUtility placesDictionary:places];
    self.sizesOfPlacesDictionary = [FlickrFetcherUtility sizesOfDictionary:self.places];
    self.placesArray = [self.places allKeys];
    self.places = [FlickrFetcherUtility sortPlaces:self.places];
    
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
    if ([[segue identifier] isEqualToString:@"topPlacesPhotoCellSegue"])
    {
        PhotoViewController *photoVC = [segue destinationViewController];
        [photoVC setPhotoDetails:[self getPhotoDetailsForCell:sender]];
    }
    
}
         
- (NSDictionary *)getPhotoDetailsForCell:(UITableViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    UITableViewHeaderFooterView *headerView = [self.tableView headerViewForSection:cellIndexPath.section];
    NSArray *placesForSection = [self.places objectForKey:headerView.textLabel.text];
    NSDictionary *placeDetails = placesForSection[cellIndexPath.row];
    return placeDetails;
}

@end
