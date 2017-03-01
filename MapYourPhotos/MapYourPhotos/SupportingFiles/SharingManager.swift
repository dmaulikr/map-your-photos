//
//  SharingManager.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 2/26/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import ArcGIS

struct SharingManager {
    //initializer with empty parameters
    static var sharedInstance = SharingManager()
    
    //properties
    var map: AGSMap!
    var geoElementsArray = [AGSGeoElement]()
}
