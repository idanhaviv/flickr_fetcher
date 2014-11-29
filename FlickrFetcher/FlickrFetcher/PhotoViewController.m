//
//  PhotoViewController.m
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 9/8/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcherUtility.h"
#import "FlickrFetcher.h"

@interface PhotoViewController () <NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSDictionary *photoDetails;

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
    NSURL *photoURL = [FlickrFetcher URLforPhoto:self.photoDetails format:FlickrPhotoFormatOriginal];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:photoURL];
    [downloadTask resume];
}

- (void)setPhotoDetails:(NSDictionary *)photoDetails
{
    _photoDetails = photoDetails;
}

#pragma mark - NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.progressView setHidden:YES];
        [self.imageView setImage:[UIImage imageWithData:data]];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"unhandled");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.progressView setProgress:progress];
    });
}

@end
