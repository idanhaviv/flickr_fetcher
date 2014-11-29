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

//@return a dictionary: keys = countries, values = array of places in that country
+ (NSMutableDictionary *)placesDictionary:(NSArray *)places
{
    NSMutableDictionary *placesDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary *place in places)
    {
        NSArray *placeDetails = [[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@","]; //first 2 entries are specific and third is country
        if ([placeDetails count] != 3)
        {
            NSLog(@"place details aren't as expected");
            continue;
        }
        
        NSString *country = placeDetails[2];
        NSString *specificLocation = [[placeDetails[0] stringByAppendingString:@","] stringByAppendingString:placeDetails[1]];
        if (![placesDictionary objectForKey:placeDetails[2]]) //placeTree doesn't contain country entree
        {
            NSMutableArray *specificLocationsForCountry = [[NSMutableArray alloc] init];
            [placesDictionary setObject:specificLocationsForCountry forKey:country];
        }
        
        [[placesDictionary objectForKey:country] addObject:specificLocation];
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

+ (void)dictionaryForTopPlaces:(void(^)(NSData *, NSError *))successBlock
{
    NSURL *urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:urlForTopPlaces
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

+ (NSDictionary *)sortPlaces:(NSDictionary *)places
{
    for (NSString *place in [places allKeys])
    {
        NSArray *placesArray = [places objectForKey:place];
        placesArray = [placesArray sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSComparisonResult result = [obj1 caseInsensitiveCompare:obj2];
            return result;
        }];
        
        [places setValue:placesArray forKey:place];
    }
    
    return places;
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
