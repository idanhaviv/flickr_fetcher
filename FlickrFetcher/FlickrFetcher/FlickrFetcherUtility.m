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

//@return a dictionary: keys = countries, values = dictionaries of photos details in that country
+ (NSMutableDictionary *)placesDictionary:(NSArray *)places
{
    NSMutableDictionary *placesDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary *place in places)
    {
        NSArray *placeDetails = [[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@","]; //last entry is country
        
        NSString *country = [placeDetails lastObject];
        
        if (![placesDictionary objectForKey:country])
        {
            NSMutableArray *specificLocationsForCountry = [[NSMutableArray alloc] init];
            [placesDictionary setObject:specificLocationsForCountry forKey:country];
        }
        
        [[placesDictionary objectForKey:country] addObject:place];
    }

    return placesDictionary;
}

+ (NSURL *)urlForPhoto:(NSDictionary *)photo
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

+ (void)dictionaryForUrl:(NSURL *)url completionBlock:(void(^)(NSData *data, NSError *error))successBlock
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   successBlock(data, error);
           }];
    [task resume];
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

#pragma mark - general utilities

+ (NSDictionary *)sortPlaces:(NSDictionary *)topPlacesDictionary
{
    for (NSString *country in [topPlacesDictionary allKeys])
    {
        NSArray *placesInCountry = [topPlacesDictionary objectForKey:country];
        placesInCountry = [placesInCountry sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSString *firstPlace = [obj1 objectForKey:FLICKR_PLACE_NAME];
            NSString *secondPlace = [obj2 objectForKey:FLICKR_PLACE_NAME];
            NSComparisonResult result = [firstPlace caseInsensitiveCompare:secondPlace];
            return result;
        }];
        
        [topPlacesDictionary setValue:placesInCountry forKey:country];
    }
    
    return topPlacesDictionary;
}

+ (NSArray *)sizesOfDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *sizes = [[NSMutableArray alloc] init];
    for (NSArray *item in [dictionary allValues])
    {
        NSUInteger cnt = [item count];
        NSNumber *num = [NSNumber numberWithInteger:cnt];
        [sizes addObject:num];
    }
    
    return sizes;
}

@end
