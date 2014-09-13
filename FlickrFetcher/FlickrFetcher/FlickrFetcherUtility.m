//
//  FlickrFetcherViewController.m
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 9/3/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import "FlickrFetcherUtility.h"
#import "FlickrFetcher.h"

@implementation FlickrFetcherUtility

+ (void)boom
{
    
    NSDictionary *res = [FlickrFetcherUtility dictionaryForTopPlaces];
    NSDictionary *dict = [res valueForKeyPath:FLICKR_RESULTS_PLACES];
//    NSLog(@"dictionaryForTopPlaces is: %@", res);
//    NSLog(@"dictionary[place] is: %@", ress);
    NSArray *photosForPlace = [self photosDictionariesForPlace:@"sv0jEhFVVr8ROg" maxResults:5];
    NSURL *url0 = [self getUrlForPhoto:photosForPlace[0]];
    

}

+ (NSURL *)getUrlForPhoto:(NSDictionary *)photo
{
    NSArray *objects = @[photo[@"farm"], photo[@"server"], photo[@"id"], photo[@"secret"], photo[@"originalsecret"], photo[@"originalformat"]];
    NSArray *keys =@[@"farm", @"server", @"id", @"secret", @"originalsecret", @"originalformat"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects
                                                     forKeys:keys];
    
    NSURL *url = [FlickrFetcher URLforPhoto:dict format:FlickrPhotoFormatOriginal];
    return url;
}

+ (NSArray *)photosDictionariesForPlace:(id)placeId maxResults:(NSInteger)maxResults
{
    NSURL *urlForPhotos = [FlickrFetcher URLforPhotosInPlace:placeId maxResults:maxResults];
    NSError *error;
    NSData *dataForphotos = [NSData dataWithContentsOfURL:urlForPhotos];
    NSDictionary *dictionaryForPhotos = [NSJSONSerialization JSONObjectWithData:dataForphotos
                                                                        options:0
                                                                          error:&error];
    NSArray *photosForPlace = [dictionaryForPhotos valueForKeyPath:FLICKR_RESULTS_PHOTOS];
    NSLog(@"%@", photosForPlace);
    return photosForPlace;
}

+ (NSDictionary *)dictionaryForTopPlaces
{
    NSError *error;
    NSURL *urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
    NSData *dataForTopPlaces = [NSData dataWithContentsOfURL:urlForTopPlaces];
    NSDictionary *dictionaryForTopPlaces = [NSJSONSerialization JSONObjectWithData:dataForTopPlaces
                                                                           options:0
                                                                             error:&error];
    return dictionaryForTopPlaces;
}

+ (NSDictionary *)dictionaryForPhotosInPlace:(id)placeId maxResults:(int)maxResults
{
    NSError *err;
    NSString *placeIdString = [NSString stringWithFormat:@"%@", placeId];
    NSURL *urlForPhotosInPlace = [FlickrFetcher URLforPhotosInPlace:placeIdString
                                                         maxResults:maxResults];
    NSData *dataForPhotosInPlace = [NSData dataWithContentsOfURL:urlForPhotosInPlace];
    NSDictionary *dictionaryForPhotosInPlace = [NSJSONSerialization JSONObjectWithData:dataForPhotosInPlace
                                                                               options:0
                                                                                 error:&err];
    return dictionaryForPhotosInPlace;
}

@end
