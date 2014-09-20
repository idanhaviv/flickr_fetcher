//
//  PhotoViewController.m
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 9/8/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcherUtility.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *photoURL = [FlickrFetcherUtility urlForPhoto:self.photoDetails];
}

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
