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

@interface FlickrFetcherTableViewController ()

@property NSDictionary *topPlacesDictionary;
@property NSDictionary *placesTree;
@property NSArray *sizesOfPlacesTree;

@end

@implementation FlickrFetcherTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.topPlacesDictionary = [FlickrFetcherUtility dictionaryForTopPlaces];
    NSArray *places = [self.topPlacesDictionary valueForKeyPath:FLICKR_RESULTS_PLACES];
    self.placesTree = [FlickrFetcherUtility placesTree:places];
    NSLog(@"places tree: %@", self.placesTree);
    self.sizesOfPlacesTree = [FlickrFetcherUtility sizesOfDictionary:self.placesTree];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sizesOfPlacesTree count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sizesOfPlacesTree[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"this is row %d in section %d", indexPath.row, indexPath.section];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
