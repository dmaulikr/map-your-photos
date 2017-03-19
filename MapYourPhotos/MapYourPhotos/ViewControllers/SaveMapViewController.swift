//
//  SaveMapViewController.swift
//  MapYourPhotos
//
//  Created by Garima Dhakal on 2/26/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import UIKit
import ArcGIS

class SaveMapViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    private var featureCollectionTable: AGSFeatureCollectionTable!
    private var featureCollectionLayer: AGSFeatureCollectionLayer!
    private var fieldsArray = [AGSField]()
    var map: AGSMap!
    var geoElementsArray: [AGSGeoElement]!
    
    private let clientID = "TxFyAuhPDc82MPNR"
    private let portalURL = URL(string:"https://www.arcgis.com")!
    private let webmapURL = "https://www.arcgis.com/home/webmap/viewer.html?webmap="
    
    override func viewDidLoad() {
        //add self as the text field delegate
        self.titleTextField.delegate = self
        self.tagsTextField.delegate = self
        
        //looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SaveMapViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //run tasks in background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.createFields()
            self.createFeatureLayer()
        }
        
    }
    
    
    //MARK: - Calls this function when the tap is recognized.
    
    func dismissKeyboard() {
        //causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    
    //MARK: - UITextFieldDelegate method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dismiss keyboard
        self.titleTextField.resignFirstResponder()
        self.tagsTextField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Create fields
    
    func createFields () {
        let descriptionField = AGSField.textField(withName: "description", alias: "description", length: 500)
        let dateField = AGSField.dateField(withName: "date", alias: "date")
        self.fieldsArray.append(descriptionField)
        self.fieldsArray.append(dateField)
    }
    
    
    //MARK: - Save map to portal
    
    func saveMapToPortal(title:String!, tags:[String]!, description:String?) {
        //Auth Manager settings
        let config = AGSOAuthConfiguration(portalURL: nil, clientID: self.clientID, redirectURL: nil)
        AGSAuthenticationManager.shared().oAuthConfigurations.add(config)
        AGSAuthenticationManager.shared().credentialCache.removeAllCredentials()
        
        //instantiate portal
        let portal = AGSPortal(url: self.portalURL, loginRequired: true)
        
        portal.load(completion: {(error) -> Void in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
            } else {
                SVProgressHUD.show(withStatus: "Saving")
                
                //instantiate portal item
                let portalItem = AGSPortalItem(portal: portal)
                portalItem.type = AGSPortalItemType.webMap
                portalItem.title = title
                portalItem.tags = tags
                if let description = description {
                    portalItem.itemDescription = description
                }
                
                do {
                    //initialize an AGSPortalItemContentParameter object with map json.
                    let contentParams = try AGSPortalItemContentParameters.init(json: self.map.toJSON())
                    
                    //add item to portal
                    portal.user?.add(portalItem, with: contentParams, to: nil, completion: {(error) -> Void in
                        if let error = error {
                            SVProgressHUD.showError(withStatus: error.localizedDescription)
                        } else { //success
                            SVProgressHUD.dismiss()
                            self.showSuccess()
                        }
                    })
                } catch {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
        })
    }
    
    
    //MARK: - Create feature layer from feature collection and add it to map
    
    func createFeatureLayer() {
        //initialize feature collection table with geo elements and its fields
        self.featureCollectionTable = AGSFeatureCollectionTable.init(geoElements: self.geoElementsArray, fields: self.fieldsArray)
        
        //since feature collection table initialization will take some time to complete
        self.featureCollectionTable.load(completion: {(error) -> Void in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
            } else {
                //initialize feature collection
                let featureCollection = AGSFeatureCollection.init(featureCollectionTables: [self.featureCollectionTable])
                
                //initialize feature collection layer
                self.featureCollectionLayer = AGSFeatureCollectionLayer.init(featureCollection: featureCollection)
                
                //add the feature collection layer to map
                self.map.operationalLayers.add(self.featureCollectionLayer)
            }
        })
    }
    
    
    //MARK: - Present an alert view controller when map is saved
    
    private func showSuccess() {
        let alertController = UIAlertController(title: "Saved successfully", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { [weak self] (action:UIAlertAction!) -> Void in
            //remove operational layers on map
            self?.map.operationalLayers.removeAllObjects()
            //dismiss view controller
            self?.dismiss(animated: true, completion: nil)
        })
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
            
            //create an array of string
            var tagsArray = tags.components(separatedBy: ",")
        
            tagsArray = tagsArray.map ({
                //remove white space prefix in the string
                $0.trimmingCharacters(in: CharacterSet.whitespaces)
            })
            
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
