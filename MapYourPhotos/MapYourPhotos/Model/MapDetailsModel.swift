//
//  MapDetailsModel.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 7/30/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import Foundation
import ArcGIS

struct MapDetailsModel {
    
    func configureAuthenticationManagerSettings() {
        let config = AGSOAuthConfiguration(portalURL: URL(string: URLConstants.PORTAL_URL)!, clientID: StringConstants.kClientId, redirectURL: nil)
        AGSAuthenticationManager.shared().oAuthConfigurations.add(config)
        AGSAuthenticationManager.shared().credentialCache.enableAutoSyncToKeychain(withIdentifier: StringConstants.kKeychainIdentifier, accessGroup: nil, acrossDevices: false)
    }
    
    
    func getFields() -> [AGSField] {
        var fields = [AGSField]()
        let descriptionField = AGSField.textField(withName: FieldConstants.description, alias: FieldConstants.description, length: FieldConstants.descriptionFieldSize)
        let dateField = AGSField.dateField(withName: FieldConstants.date, alias: FieldConstants.date)
        fields.append(descriptionField)
        fields.append(dateField)
        return fields
    }
    
    
    func getPortalItem(with portal: AGSPortal, and item: PortaItemInfo) -> AGSPortalItem {
        let portalItem = AGSPortalItem(portal: portal)
        portalItem.type = AGSPortalItemType.webMap
        portalItem.title = item.title
        portalItem.tags = item.tags
        portalItem.itemDescription = (item.description.isEmpty) ? "" : item.description
        return portalItem
    }
    
    
    func save(_ item: AGSPortalItem, and map: AGSMap, completion: @escaping (Error?) -> Void) -> Void {
        do {
            //initialize an AGSPortalItemContentParameter object with map json.
            let contentParams = try AGSPortalItemContentParameters(json: map.toJSON())
            
            //add item to portal
            item.portal.user?.add(item, with: contentParams, to: nil) {(error) -> Void in
                if let error = error {
                    completion(error)
                } else { //success
                    completion(nil)
                }
            }
        } catch let err {
            completion(err)
        }
    }
    
    
    func createFeatureCollectionLayer(from geoElements: [AGSGeoElement], and fields: [AGSField], completion: @escaping (LayerResultType) -> Void) -> Void {
        //initialize feature collection table with geo elements and its fields
        let featureCollectionTable = AGSFeatureCollectionTable(geoElements: geoElements, fields: fields)
        
        //since feature collection table initialization will take some time to complete
        featureCollectionTable.load { (error) -> Void in
            if let error = error {
                completion(LayerResultType.Error(e: error))
            } else {
                //initialize feature collection
                let featureCollection = AGSFeatureCollection(featureCollectionTables: [featureCollectionTable])
                //initialize feature collection layer
                let featureCollectionLayer = AGSFeatureCollectionLayer(featureCollection: featureCollection)
                completion(LayerResultType.Success(r: featureCollectionLayer))
            }
        }
    }
    
    
    func connectToPortal(completion: @escaping (PortalConnectionResultType) -> Void) -> Void {
        let portal = AGSPortal(url: URL(string: URLConstants.PORTAL_URL)!, loginRequired: true)
        portal.load { (error) -> Void in
            if let error = error {
                completion(PortalConnectionResultType.Error(e: error))
            } else {
                completion(PortalConnectionResultType.Success(r: portal))
            }
        }
    }
    
}
