//
//  ViewController.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 12/15/16.
//  Copyright © 2016 Garima Dhakal. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, UISearchBarDelegate, AGSGeoViewTouchDelegate, AGSPopupsViewControllerDelegate {
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    private var map: AGSMap!
    private var pointGraphicOverlay: AGSGraphicsOverlay!
    private var popupsVC:AGSPopupsViewController!
    private var graphicsArray = [AGSGraphic]()
    private var VECTOR_TILE_URL = URL(string:"https://basemaps.arcgis.com/v1/arcgis/rest/services/World_Basemap/VectorTileServer")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set map view background
        let mapViewBackground = AGSBackgroundGrid.init(color: .white, gridLineColor: .white, gridLineWidth: 5, gridSize: 10)
        self.mapView.backgroundGrid = mapViewBackground
        
        //create an instance of vector tiled layer
        let vectorTiledLayer = AGSArcGISVectorTiledLayer.init(url: VECTOR_TILE_URL)
        
        //create an instance of a map with vector tiled layer as basemap
        self.map = AGSMap(basemap: AGSBasemap(baseLayer: vectorTiledLayer))
        
        //assign map to the map view
        self.mapView.map = self.map
        
        //create an instance of graphics overlay
        self.pointGraphicOverlay = AGSGraphicsOverlay()
        self.mapView.graphicsOverlays.add(self.pointGraphicOverlay)
        
        //add self as the touch delegate for the map view
        self.mapView.touchDelegate = self
        
        //add self as the search bar delegate
        self.searchBar.delegate = self
    }
    
    
    //MARK: - Convert Data to JSON objects
    
    func convertDataToObject(jsonData: Data) {
        do {
            guard let parsedResult = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? NSDictionary else {
                return
            }
            let items = parsedResult.object(forKey: "items") as! NSArray
            if items.count > 0 {
                //create graphics and add them to map
                self.addGraphics(arrayOfItems: items)
            }
        } catch {
             SVProgressHUD.showInfo(withStatus: "Could not get data. Try another tag.")
        }
    }
    
    
    //MARK: - Create graphics and add them to map
    
    func addGraphics (arrayOfItems: NSArray) {
        //picture marker symbol
        let pictureMarkerSymbol = AGSPictureMarkerSymbol.init(image: #imageLiteral(resourceName: "flickr.png"))
        pictureMarkerSymbol.height = 20
        pictureMarkerSymbol.width = 20
        
        for item in arrayOfItems {
            let longStr = (item as AnyObject).object(forKey: "longitude") as! String
            let latStr = (item as AnyObject).object(forKey:"latitude") as! String
            let longitude = Double(longStr)
            let latitude = Double(latStr)
            //create an instance of point
            let point = AGSPoint(x: longitude!, y: latitude!, spatialReference: AGSSpatialReference.wgs84())
            
            //attributes
            var attributes = [String:Any]()
            attributes["description"] = (item as AnyObject).object(forKey:"description") as! String
            let dateTaken = (item as AnyObject).object(forKey:"date_taken") as! String
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            let dateObj = dateFormatter.date(from: dateTaken)
            attributes["date"] = dateObj
            
            //create a graphic
            let graphic = AGSGraphic.init(geometry: point, symbol:pictureMarkerSymbol, attributes: attributes)
            
            //populate array
            self.graphicsArray.append(graphic)
        }
        
        //dismiss progress hud
        SVProgressHUD.dismiss()
        
        //add an array of graphics objects to graphics overlay
        self.pointGraphicOverlay.graphics.addObjects(from: self.graphicsArray)
        
        //set map view location
        let viewpoint = AGSViewpoint.init(targetExtent: self.pointGraphicOverlay.extent)
        self.mapView.setViewpoint(viewpoint)
    }
    
    
    // MARK: - Create Popup
    
    private func popupContent(result: AGSIdentifyGraphicsOverlayResult) {
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
            let popup = AGSPopup.init(geoElement: graphic, popupDefinition: popupInfo)
            
            //populate popup array
            popupArray.append(popup)
            
        }
        //create popup view controller with popup array
        self.popupsVC = AGSPopupsViewController.init(popups: popupArray, containerStyle: .navigationBar)
        
        //add self as the delegate for the popup view controller
        self.popupsVC.delegate = self
        
        //show popup view controller
        self.present(self.popupsVC, animated: true, completion: nil)
    }

    
    //ACTION: - Navigation

    @IBAction func saveAction(_ sender: Any) {
        //present view controller if pointGraphicOverlay contains graphics
        if self.pointGraphicOverlay.graphics.count > 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SaveMapViewController") as! SaveMapViewController
            controller.map = self.map
            //create an array of AGSGeoElement from graphicsArray and assign it to geoElementsArray
            let geoElementsArray = self.graphicsArray.map{$0 as AGSGeoElement}
            controller.geoElementsArray = geoElementsArray
            self.present(controller, animated: true, completion: nil)
        } else {
            SVProgressHUD.showInfo(withStatus: "There is no data on map to save.")
        }
    }
    
    
    //MARK: - UISearchBarDelegate methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //close keyboard
        self.searchBar.resignFirstResponder()
        
        //remove existing graphics
        self.pointGraphicOverlay.graphics.removeAllObjects()
        self.graphicsArray.removeAll()
        
        let tag = self.searchBar.text! as String
        
        //validation
        if (!tag.characters.contains(" ")) {
            //show status
            SVProgressHUD.show(withStatus: "Fetching data")
            
            //URL to fetch data from Flickr public feed
            let createUrl = "https://api.flickr.com/services/feeds/geo?tagmode=all&tags=\(tag)&format=json&nojsoncallback=1"
            let flickrURL = URL(string: createUrl)
            
            //fetch data
            let session = URLSession.shared
            (session.dataTask(with: flickrURL!, completionHandler: { [weak self] (data: Data?, response, error) -> Void in
                if let error = error {
                    //show error
                    SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
                } else {
                    //convert Data to JSON objects
                    self?.convertDataToObject(jsonData: data!)
                }
            })).resume()
        } else {
            //tags not valid
            SVProgressHUD.showInfo(withStatus: "Not a valid input. Please try again.")
        }
    }
    
    
    //MARK: - AGSGeoViewTouchDelegate method
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        if(self.pointGraphicOverlay.graphics.count == 0) {
            //hide keyboard
            self.searchBar.resignFirstResponder()
        } else {
            let tolerance:Double = 3
            //identify graphics on a graphic overlay
            self.mapView.identify(self.pointGraphicOverlay, screenPoint: screenPoint, tolerance: tolerance, returnPopupsOnly: false, maximumResults: 10) { (result: AGSIdentifyGraphicsOverlayResult) -> Void in
                if let error = result.error {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                } else { //if graphic is found then create popup
                    if(result.graphics.count > 0) {
                        self.popupContent(result: result)
                    } else { //hide keyboard
                        self.searchBar.resignFirstResponder()
                    }
                }
            }
        }
    }
    
    
    //MARK: - AGSPopupsViewControllerDelegate method
    
    func popupsViewControllerDidFinishViewingPopups(_ popupsViewController: AGSPopupsViewController) {
        //dismiss popups view controller
        self.dismiss(animated: true, completion:nil)
        self.popupsVC = nil
    }

}



