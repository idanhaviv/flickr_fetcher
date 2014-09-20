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
    NSArray *places = [res valueForKeyPath:FLICKR_RESULTS_PLACES];
//    NSLog(@"dictionaryForTopPlaces is: %@", res);
//    NSLog(@"dictionary[place] is: %@", ress);
//    NSArray *photosForPlace = [self photosDictionariesForPlace:@"sv0jEhFVVr8ROg" maxResults:5];
//    NSURL *url0 = [self getUrlForPhoto:photosForPlace[0]];
    
    NSDictionary *dictionary = [self placesDictionary:places];
    

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

+ (NSMutableDictionary *)placesDictionary:(NSArray *)places //returns a dictionary: keys = countries, values = array of places in that country
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

+ (NSDictionary *)dictionaryForTopPlaces
{
    NSError *error;
    NSURL *urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
    NSData *dataForTopPlaces = [NSData dataWithContentsOfURL:urlForTopPlaces]; // synchronous (bad practice)
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
