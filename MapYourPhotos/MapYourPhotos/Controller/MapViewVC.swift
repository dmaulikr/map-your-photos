//
//  ViewController.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 12/15/16.
//  Copyright © 2016 Garima Dhakal. All rights reserved.
//

import UIKit
import ArcGIS

protocol MapViewVCDataDelegate {
    func passData(map: AGSMap, geoElementsArray: [AGSGeoElement])
}


class MapViewVC: UIViewController {
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var map: AGSMap!
    fileprivate var pointGraphicOverlay: AGSGraphicsOverlay!
    fileprivate var popupsVC:AGSPopupsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set map view background
        let mapViewBackground = AGSBackgroundGrid.init(color: .white, gridLineColor: .white, gridLineWidth: 5, gridSize: 10)
        self.mapView.backgroundGrid = mapViewBackground
        
        //create an instance of a map with streets vector basemap
        self.map = AGSMap(basemap: AGSBasemap.streetsVector())
        
        //assign map to the map view
        self.mapView.map = self.map
        
        //create an instance of graphics overlay and add it to map view
        self.pointGraphicOverlay = AGSGraphicsOverlay()
        self.mapView.graphicsOverlays.add(self.pointGraphicOverlay)
        
        //add self as the touch delegate for the map view
        self.mapView.touchDelegate = self
        
        //add self as the search bar delegate
        self.searchBar.delegate = self
    }

    
    //MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == StringConstants.kSegueIdentifier else { return true }
        
        //perform segue if the list of graphics in the graphics overlay is not empty
        if self.pointGraphicOverlay.graphics.count > 0 {
            return true
        } else {
            SVProgressHUD.showInfo(withStatus: "There is no data on map to save.")
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StringConstants.kSegueIdentifier {
            let geoElementsArray = self.pointGraphicOverlay.graphics.map{$0 as! AGSGeoElement}
            let saveMapVC = segue.destination as! MapDetailsVC
            saveMapVC.mapDataDelegate = saveMapVC
            saveMapVC.mapDataDelegate!.passData(map: self.map, geoElementsArray: geoElementsArray)
        }
    }

}



extension MapViewVC: UISearchBarDelegate, AGSGeoViewTouchDelegate, AGSPopupsViewControllerDelegate {
    
    
    //MARK: - UISearchBarDelegate methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //close keyboard
        self.searchBar.resignFirstResponder()
        
        //remove existing graphics
        self.pointGraphicOverlay.graphics.removeAllObjects()
        
        var tag = self.searchBar.text! as String
        if(tag.contains(" ")) {
            //remove whitespaces in tag
            tag = tag.replacingOccurrences(of: " ", with: "")
        }
        
        SVProgressHUD.show(withStatus: "Fetching data")
        
        FetchPhotosClient().fetchPhotos(with: tag) { (result) in
            SVProgressHUD.dismiss()
            switch result {
            case .Success(let results):
                if let arrayOfGraphics = MapModel().getGraphics(from: results) {
                     self.pointGraphicOverlay.graphics.addObjects(from: arrayOfGraphics)
                    //set map view location
                    let viewpoint = AGSViewpoint.init(targetExtent: self.pointGraphicOverlay.extent)
                    self.mapView.setViewpoint(viewpoint)
                } else {
                    SVProgressHUD.showInfo(withStatus: "No results found. Try a different tag.")
                }
            case .Error(let e):
                SVProgressHUD.showInfo(withStatus: e.localizedDescription)
            }
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
                } else {
                    //if graphic is found then create popup
                    if(result.graphics.count > 0) {
                        let popupArray = MapModel().popupContent(from: result)
                        //create popup view controller with popup array
                        self.popupsVC = AGSPopupsViewController(popups: popupArray, containerStyle: .navigationBar)
                        
                        //add self as the delegate for the popup view controller
                        self.popupsVC.delegate = self
                        
                        //show popup view controller
                        self.present(self.popupsVC, animated: true, completion: nil)
                    } else {
                        //hide keyboard
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



