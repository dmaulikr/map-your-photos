
## About

This project showcases a proof of concept to demonstrate the capability of ArcGIS platform to visualize and store geo-tagged images from social media platforms such as Flickr. This mapping application uses ArcGIS runtime SDK for iOS to visualize geo-tagged images, which is derived from Flickr public feed and to store the webmap to ArcGIS Online cloud platform.

*This project was submitted to Esri's internal [Runtime Quartz Hackathon 2016](https://blogs.esri.com/esri/arcgis/2017/01/06/runtime-quartz-hackathon-results/). Link to [Devpost](https://devpost.com/software/map-your-photos).*

## Features
* Search photos by tags: *Displays search results in graphics overlay* <img src="https://cloud.githubusercontent.com/assets/8196343/23489379/e3adae46-fea6-11e6-9eb6-4c6b7444fda2.png" alt="alt text" width="250" height="400">

* Select graphic to display popup: *Popup contains photo description* <img src="https://cloud.githubusercontent.com/assets/8196343/23489403/0567b752-fea7-11e6-8d64-11fe1c102e90.png" alt="alt text" width="250" height="400">

* Webmap details: *Enter details to describe the webmap* <img src="https://cloud.githubusercontent.com/assets/8196343/23489455/4ecdfea6-fea7-11e6-8c92-4bc20488b94f.png" alt="alt text" width="250" height="400">

* Authentication: *Sign in to ArcGIS Online via OAuth and save the webmap to your user account* <img src="https://cloud.githubusercontent.com/assets/8196343/23490723/ed1708ee-feae-11e6-96d9-74843d608b9f.png" alt="alt text" width="250" height="400">

* Access the webmap in ArcGIS Online: *View and modify the saved webmap in ArcGIS Online*
<img width="1098" alt="agol" src="https://cloud.githubusercontent.com/assets/8196343/23489500/9b5a02a6-fea7-11e6-9caf-8a1e4b272253.png">

## Setting Up The Project

* Sign up for free [Developers account](https://developers.arcgis.com/sign-in/) and [install](https://developers.arcgis.com/ios/latest/swift/guide/install.htm) ArcGIS Runtime SDK for iOS 100.0.
* Open the project in Xcode and run on a simulator or an iPhone device. It requires Xcode 8 (or higher) and iOS 10 SDK (or higher) and you would need to add [ArcGIS Resource bundle](https://developers.arcgis.com/ios/latest/swift/guide/install.htm#ESRI_SECTION2_0A8B5D37BCC649448D1A771ECBAE101A) to the project.
* Programming language: Swift 3.0.
