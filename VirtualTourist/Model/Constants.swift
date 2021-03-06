//
//  Constants.swift
//  VirtualTourist
//
//  Created by user140243 on 6/3/18.
//  Copyright © 2018 jlhoopes.com. All rights reserved.
//

import Foundation

struct Constants {
    struct StoryboardIDs {
        static let MapView = "MapViewController"
        static let SegueID = "locationCollectionSegue"
        static let LocationView = "LocationCollectionViewController"
        static let CellReuseID = "imageCell"
        static let PinReuseID = "pin"
    }
    
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        //Personal API Key
        static let APIKey = "9f2d4591298eeedac39f2af636aebbc9"
        static let ResponseFormat = "json"
        static let UseSafeSearch = "1"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let latitude = "lat"
        static let longitude = "lon"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
    }
    
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
}
