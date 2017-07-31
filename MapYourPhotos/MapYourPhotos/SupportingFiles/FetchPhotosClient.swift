//
//  FetchPhotosClient.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 7/29/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import UIKit
import ArcGIS

struct FetchPhotosClient {
    
     func fetchPhotos(with tag: String, completion: @escaping (FetchResultType) -> Void) -> Void {
        let createUrl = "https://api.flickr.com/services/feeds/geo?tagmode=all&tags=\(tag)&format=json&nojsoncallback=1"
        let flickrURL = URL(string: createUrl)!
        
        let task = URLSession.shared.dataTask(with: flickrURL) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(FetchResultType.Error(e: error))
                }
            }
            
            guard let data = data else {
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
            }
            
            do {
                 if let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    let items = result.object(forKey: "items") as! [NSDictionary]
                    DispatchQueue.main.async {
                        completion(FetchResultType.Success(r: items))
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(FetchResultType.Error(e: error))
                }
            }
        }
        
        task.resume()
        
    }

}
