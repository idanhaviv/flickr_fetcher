//
//  FlickrFetcherViewController.h
//  FlickrFetcher
//
//  Created by Haviv, Idan [ICG-IT] on 9/3/14.
//  Copyright (c) 2014 idan.haviv.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface FlickrFetcherUtility : NSObject

+ (NSDictionary *)dictionaryForTopPlaces;
+ (NSDictionary *)dictionaryForPhotosInPlace:(id)placeId maxResults:(int)maxResults;
+ (void)boom;

@end