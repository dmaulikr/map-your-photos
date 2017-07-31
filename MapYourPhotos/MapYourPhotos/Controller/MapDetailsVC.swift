//
//  SaveMapViewController.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 2/26/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import UIKit
import ArcGIS

class MapDetailsVC: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    private var portal: AGSPortal!
    
    var mapDataDelegate: MapViewVCDataDelegate?
    fileprivate var map: AGSMap!
    fileprivate var geoElementsArray: [AGSGeoElement]!
    
    
    override func viewDidLoad() {
        //add self as the text field delegate
        self.titleTextField.delegate = self
        self.tagsTextField.delegate = self
        
        //looks for single or multiple taps
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapDetailsVC.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //OAuth configurations
        MapDetailsModel().configureAuthenticationManagerSettings()
    }
    
    
    //MARK: - Calls this method when the tap is recognized.
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    //ACTION: - Done button is clicked
   
    @IBAction func doneAction(_ sender: Any) {
        //Validations
        guard let title = self.titleTextField.text, title != "", let tags = self.tagsTextField.text, tags != "" else {
            SVProgressHUD.showError(withStatus: "Title and tags are required fields.")
            return
        }
        
        SVProgressHUD.show(withStatus: "Saving Map")
        
        let tagsArray = tags.components(separatedBy: ",").map {
            //remove white space prefix in the string
            $0.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        
        let itemDescription = (self.descriptionTextView.text.isEmpty) ? "" : self.descriptionTextView.text
        
        //use Struct PortalItemInfo to store title, tags, and description
        let itemInfo = PortaItemInfo(title: title, tags: tagsArray, description: itemDescription!)
        
        //set up portal and map and save
        self.configureMapAndPortalAndSave(itemInfo)
    }
    
    
    //MARK: - Save map to portal
    
    func configureMapAndPortalAndSave(_ item: PortaItemInfo) {
        //to avoid adding duplicate feature collection layers on map
        if self.map.operationalLayers.count == 0 {
            self.addFeatureCollectionLayerToMap()
        }
        
        if self.portal == nil {
            MapDetailsModel().connectToPortal(completion: { (result) in
                switch result {
                case .Success(let portal): //save item
                    self.portal = portal
                    self.saveItemToPortal(item)
            
                case .Error(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            })
        } else { //save item
            self.saveItemToPortal(item)
        }
    }
    
    //MARK: - Save portal item to map
    
    func saveItemToPortal(_ item: PortaItemInfo) {
        
        guard self.portal.loadStatus == .loaded else {
            SVProgressHUD.showError(withStatus: "Could not connect to Portal. Try again.")
            return
        }
        
        let portalItem = MapDetailsModel().getPortalItem(with: self.portal, and: item)
        
        MapDetailsModel().save(portalItem, and: self.map, completion: { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            } else {
                SVProgressHUD.dismiss()
                self.showSuccess()
            }
        })
        
    }
    
    
    //MARK: - Create feature collecion layer and add it to map
    
    func addFeatureCollectionLayerToMap() {
        MapDetailsModel().createFeatureCollectionLayer(from: self.geoElementsArray, and: MapDetailsModel().getFields()) { (result) in
            switch result {
            case .Success(let featureCollectionLayer):
                self.map.operationalLayers.add(featureCollectionLayer)
            case .Error(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    
    //MARK: - Present an alert view controller when webmap is saved
    
    private func showSuccess() {
        let alertController = UIAlertController(title: "Saved successfully", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel) {(action:UIAlertAction!) -> Void in
            
            //remove operational layers on map
            self.map.operationalLayers.removeAllObjects()
            //dismiss view controller
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    //ACTION: - Cancel button is clicked
    
    @IBAction func cancelAction(_ sender: Any) {
        //dismiss view controller
        self.dismiss(animated: false, completion: nil)
    }

}



extension MapDetailsVC: MapViewVCDataDelegate, UITextFieldDelegate {
    
    //MARK: - ViewControllerDataDelegate method

    func passData(map: AGSMap, geoElementsArray: [AGSGeoElement]) {
        if(self.mapDataDelegate != nil) {
            self.map = map
            self.geoElementsArray = geoElementsArray
        }
    }
    
    
    //MARK: - UITextFieldDelegate method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dismiss keyboard
        self.titleTextField.resignFirstResponder()
        self.tagsTextField.resignFirstResponder()
        return true
    }

}
