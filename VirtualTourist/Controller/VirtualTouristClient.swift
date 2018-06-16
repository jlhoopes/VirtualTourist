//
//  VirtualTouristClient.swift
//  VirtualTourist
//
//  Created by Jason on 6/14/18.
//  Copyright © 2018 jlhoopes.com. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VirtualTouristClient: NSObject {
    
    static let shared = VirtualTouristClient()
    
    override init() {
        super.init()
    }
    
    func getImagesFrom(lat: Double, long: Double, pageNumber: Int, perPage: Int?, completionHandler: @escaping(_ data: [[String:AnyObject]], _ success: Bool, _ errorString: String?) -> Void) {
        
        let url = URL(string: "https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=bd02a51a8a0078a4774f4995442fa812&lat=\(lat)&lon=\(long)&extras=url_m&format=json&nojsoncallback=?&per_page=\(perPage ?? 21)&page=\(pageNumber)")
        let request = URLRequest(url: url!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error Detected: \(error?.localizedDescription ?? "Error")")
                return
            }
            
            guard let data = data else {
                print("Unable to download Flickr data.")
                return
            }
            
            var parsedResult: [String:AnyObject]!
            do {
                parsedResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            }
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                print("Unable to access data from Flickr.")
                return
            }
            
            guard let photoDict = photos["photo"] as? [[String:AnyObject]] else {
                print("Unable to access the single photos.")
                return
            }
            
            completionHandler(photoDict, true, nil)
        }
        task.resume()
    }
}
