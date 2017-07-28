//
//  SaveMapViewController.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 2/26/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import UIKit
import ArcGIS

class SaveMapViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var viewControllerDelegate: ViewControllerDataDelegate?
    fileprivate var map: AGSMap!
    fileprivate var geoElementsArray: [AGSGeoElement]!
    private var portal: AGSPortal!
    private var featureCollectionTable: AGSFeatureCollectionTable!
    
    private let kClientId = "TxFyAuhPDc82MPNR"
    private let PORTAL_URL = URL(string:"https://ess.maps.arcgis.com")!
    private let kURLIdentifier = "MapYourPhotos://auth/"
    private let kKeychainIdentifier = "MapYourPhotos"
    
    override func viewDidLoad() {
        //add self as the text field delegate
        self.titleTextField.delegate = self
        self.tagsTextField.delegate = self
        
        //looks for single or multiple taps
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SaveMapViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //Auth Manager settings
        let config = AGSOAuthConfiguration(portalURL: PORTAL_URL, clientID: kClientId, redirectURL: nil)
        AGSAuthenticationManager.shared().oAuthConfigurations.add(config)
        AGSAuthenticationManager.shared().credentialCache.enableAutoSyncToKeychain(withIdentifier: kKeychainIdentifier, accessGroup: nil, acrossDevices: false)
    }
    
    
    //MARK: - Calls this method when the tap is recognized.
    
    func dismissKeyboard() {
        //causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    
    //MARK: - Save map to portal
    
    func saveMapToPortal(title:String!, tags:[String]!, description:String?) {
        //to avoid duplicate feature layers on map
        if self.map.operationalLayers.count == 0 {
            self.createFeatureLayer()
        }
        
        //instantiate portal
        if self.portal == nil {
            self.portal = AGSPortal(url: PORTAL_URL, loginRequired: true)
        }
        
        self.portal.load { [weak self] (error) -> Void in
            guard let weakSelf = self else {
                return
            }
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
            } else {
                SVProgressHUD.show(withStatus: "Saving")
                
                //instantiate portal item
                let portalItem = AGSPortalItem(portal: weakSelf.portal)
                portalItem.type = AGSPortalItemType.webMap
                portalItem.title = title
                portalItem.tags = tags
                if let description = description {
                    portalItem.itemDescription = description
                }
                do {
                    //initialize an AGSPortalItemContentParameter object with map json.
                    let contentParams = try AGSPortalItemContentParameters.init(json: weakSelf.map.toJSON())
                    
                    //add item to portal
                    weakSelf.portal.user?.add(portalItem, with: contentParams, to: nil) {(error) -> Void in
                        if let error = error {
                            SVProgressHUD.showError(withStatus: error.localizedDescription)
                        } else { //success
                            SVProgressHUD.dismiss()
                            weakSelf.showSuccess()
                        }
                    }
                } catch {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
        }
    }
    
    
    //MARK: - Create feature layer from feature collection and add it to map
    
    func createFeatureLayer() {
        //array of fields
        var fieldsArray = [AGSField]()
        let descriptionField = AGSField.textField(withName: "description", alias: "description", length: 500)
        let dateField = AGSField.dateField(withName: "date", alias: "date")
        fieldsArray.append(descriptionField)
        fieldsArray.append(dateField)
        
        //initialize feature collection table with geo elements and its fields
        self.featureCollectionTable = AGSFeatureCollectionTable(geoElements: self.geoElementsArray, fields: fieldsArray)
        
        //since feature collection table initialization will take some time to complete
        self.featureCollectionTable.load { [weak self] (error) -> Void in
            guard let weakSelf = self else {
                return
            }
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
            } else {
                //initialize feature collection
                let featureCollection = AGSFeatureCollection(featureCollectionTables: [weakSelf.featureCollectionTable])
                //initialize feature collection layer
                let featureCollectionLayer = AGSFeatureCollectionLayer(featureCollection: featureCollection)
                
                //add the feature collection layer to map
                weakSelf.map.operationalLayers.add(featureCollectionLayer)
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
    
    
    //ACTION: - Done button is clicked
   
    @IBAction func doneAction(_ sender: Any) {
        //Validations
        guard let title = self.titleTextField.text, let tags = self.tagsTextField.text else {
            SVProgressHUD.showError(withStatus: "Title and tags are required fields.")
            return
        }
        if title == "" || tags == "" {
            SVProgressHUD.showError(withStatus: "Title and tags are required fields.")
        } else {  //title and tags are not empty
            let tagsArray = tags.components(separatedBy: ",").map {
                //remove white space prefix in the string
                $0.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            
            var itemDescription: String?
            if !self.descriptionTextView.text.isEmpty {
                itemDescription = self.descriptionTextView.text
            }
            
            //save map to portal
            self.saveMapToPortal(title: title, tags: tagsArray, description: itemDescription)
        }
    }
    
    
    //ACTION: - Cancel button is clicked
    
    @IBAction func cancelAction(_ sender: Any) {
        //dismiss view controller
        self.dismiss(animated: false, completion: nil)
    }

}



extension SaveMapViewController: ViewControllerDataDelegate, UITextFieldDelegate {
    
    //MARK - ViewControllerDataDelegate method

    func passData(map: AGSMap, geoElementsArray: [AGSGeoElement]) {
        if(self.viewControllerDelegate != nil) {
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
