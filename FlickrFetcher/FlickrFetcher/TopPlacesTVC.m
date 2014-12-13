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
    self.navigationController.navigationBar.hidden = YES;
    //self.clearsSelectionOnViewWillAppear = NO;
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PhotosForPlaceSegue"])
    {
        PhotosForPlaceTVC *photosForPlaceTVC = [segue destinationViewController];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            photosForPlaceTVC.placeDetails = [self getPhotosDetailsForCell:sender];
        });
    }
    
}
         
- (NSDictionary *)getPhotosDetailsForCell:(UITableViewCell *)cell
{
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    NSString *place = self.placesArray[cellIndexPath.section];
    NSArray *placesForSection = [self.places objectForKey:place];
    NSDictionary *placeDetails = placesForSection[cellIndexPath.row];
    return placeDetails;
}

@end
