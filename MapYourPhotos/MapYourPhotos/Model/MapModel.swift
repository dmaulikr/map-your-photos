//
//  GraphicsModel.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 7/29/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import ArcGIS

struct MapModel {
    
    func getGraphics(from photos: [NSDictionary]) -> [AGSGraphic]? {
        guard photos.count > 0 else {
            return nil
        }
        
        //instantiate picture marker symbol
        let pictureMarkerSymbol = AGSPictureMarkerSymbol.init(image: #imageLiteral(resourceName: "flickr.png"))
        pictureMarkerSymbol.height = 30
        pictureMarkerSymbol.width = 30
        
        var graphicsArray = [AGSGraphic]()
        
        for item in photos {
            let longStr = (item as AnyObject).object(forKey: "longitude") as! String
            let latStr = (item as AnyObject).object(forKey:"latitude") as! String
            let longitude = Double(longStr)
            let latitude = Double(latStr)
            //create an instance of point
            let point = AGSPoint(x: longitude!, y: latitude!, spatialReference: AGSSpatialReference.wgs84())
            
            //create a dictionary to hold attributes of the item
            var attributes = [String:Any]()
            attributes["description"] = (item as AnyObject).object(forKey:"description") as! String
            let dateTaken = (item as AnyObject).object(forKey:"date_taken") as! String
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            let dateObj = dateFormatter.date(from: dateTaken)
            attributes["date"] = dateObj
            
            //create a graphic
            let graphic = AGSGraphic(geometry: point, symbol:pictureMarkerSymbol, attributes: attributes)
            
            //populate array
            graphicsArray.append(graphic)
        }
        return graphicsArray
    }
    
    
    func popupContent(from result: AGSIdentifyGraphicsOverlayResult) -> [AGSPopup] {
        //create an array to hold popup
        var popupArray = [AGSPopup]()
        
        //create popup for each element
        for graphic in result.graphics {
            //popup definition
            let popupInfo = AGSPopupDefinition()
            popupInfo.title = "{date}"
            popupInfo.customDescription = "{description}"
            popupInfo.allowDelete = false
            popupInfo.allowEdit = false
            popupInfo.allowEditGeometry = false
            
            //create popup
            let popup = AGSPopup(geoElement: graphic, popupDefinition: popupInfo)
            
            //populate popup array
            popupArray.append(popup)
            
        }
        return popupArray
    }
}

