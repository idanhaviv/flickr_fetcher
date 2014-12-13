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

@interface PhotoViewController () <NSURLSessionDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic) NSDictionary *photoDetails;

@end

@implementation PhotoViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *photoURL = [FlickrFetcher URLforPhoto:self.photoDetails format:FlickrPhotoFormatLarge];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:photoURL];
    [downloadTask resume];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *imageName = self.photoDetails[FLICKR_PHOTO_TITLE];
    [self prepareImageNameLabel:imageName];
}

#pragma mark - private methods


- (void)prepareImageView:(NSData *)data
{
    self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithData:data]];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.imageView.bounds.size;
}

- (void)prepareScrollViewAttributes
{
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleHeight, scaleWidth);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
}

- (void)prepareImageNameLabel:(NSString *)text
{
    UIFont *font = [UIFont fontWithName:@"Zapfino"
                                   size:20];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[@3, font]
                                                           forKeys:@[NSBaselineOffsetAttributeName, NSFontAttributeName]];

    CGSize labelSize = [text sizeWithAttributes:attributes];
    CGRect frame = CGRectMake(10, 400, labelSize.width, labelSize.height);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = [UIFont fontWithName:@"Zapfino"
                                 size:20];
    [self.view addSubview:label];
}

- (void)setPhotoDetails:(NSDictionary *)photoDetails
{
    _photoDetails = photoDetails;
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setHidden:YES];
        [self prepareImageView:data];
        [self prepareScrollViewAttributes];
        [self addGestureRecognizers];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"unhandled");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress];
    });
}

#pragma mark - GestureRecognizers

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)gestureRecognizer
{
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint pointInView = [gestureRecognizer locationInView:self.imageView];
    
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = pointInView.y - (height / 2.0f);
    
    
    CGRect rectToZoomTo = CGRectMake(x, y, width, height);
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(scrollViewDoubleTapped:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

@end
