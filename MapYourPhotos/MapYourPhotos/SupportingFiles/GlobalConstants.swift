//
//  GlobalConstants.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 7/30/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import Foundation
import ArcGIS

//Custom Data Type

struct PortaItemInfo {
    var title: String
    var tags: [String]
    var description: String
}

//Custom result type for completion block

enum PortalConnectionResultType {
    case Success(r: AGSPortal)
    case Error(e: Error)
}

enum FetchResultType {
    case Success(r: [NSDictionary])
    case Error(e: Error)
}

enum LayerResultType {
    case Success(r: AGSFeatureCollectionLayer)
    case Error(e: Error)
}

//Constants

struct StringConstants {
    static let kClientId = "TxFyAuhPDc82MPNR"
    static let kKeychainIdentifier = "MapYourPhotos"
    static let kSegueIdentifier = "toSaveMapVC"
}

struct FieldConstants {
    static let description = "description"
    static let date = "date"
    static let descriptionFieldSize = 500
}

struct URLConstants {
    static let PORTAL_URL = "https://ess.maps.arcgis.com"
}



