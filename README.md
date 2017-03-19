
## About

This project is a proof of concept to demonstrate the capabilities of ArcGIS platform to visualize and store geo-referenced images from social media platforms such as Flickr.

*Submitted to [Runtime Quartz Hackathon 2016](https://blogs.esri.com/esri/arcgis/2017/01/06/runtime-quartz-hackathon-results/).*

## Features
* Search photos by tag and display geo-referenced photos on map for the specified tag. The data is derived from Flickr public feed.

  <img src="https://cloud.githubusercontent.com/assets/8196343/23489379/e3adae46-fea6-11e6-9eb6-4c6b7444fda2.png" alt="alt text" width="250" height="400">

* Select graphics on map to display popup, which contains description of the selected photos.

  <img src="https://cloud.githubusercontent.com/assets/8196343/23489403/0567b752-fea7-11e6-8d64-11fe1c102e90.png" alt="alt text" width="250" height="400">

* Save the web map.

  <img src="https://cloud.githubusercontent.com/assets/8196343/23489455/4ecdfea6-fea7-11e6-8c92-4bc20488b94f.png" alt="alt text" width="250" height="400">

* Use OAuth to sign in to ArcGIS Online.

  <img src="https://cloud.githubusercontent.com/assets/8196343/23490723/ed1708ee-feae-11e6-96d9-74843d608b9f.png" alt="alt text" width="250" height="400">

* Access the saved webmap in ArcGIS Online.

  <img width="300" alt="agol" src="https://cloud.githubusercontent.com/assets/8196343/23489500/9b5a02a6-fea7-11e6-9caf-8a1e4b272253.png">

## Setting Up The Project

* Sign up for free [Developers account](https://developers.arcgis.com/sign-in/) and [install](https://developers.arcgis.com/ios/latest/swift/guide/install.htm) ArcGIS Runtime SDK for iOS 100.0.
* Open the project in Xcode and add [ArcGIS Resource bundle](https://developers.arcgis.com/ios/latest/swift/guide/install.htm#ESRI_SECTION2_0A8B5D37BCC649448D1A771ECBAE101A) to the project.
* Requires Xcode 8 (or higher) and iOS 10 SDK (or higher).
* Programming language: Swift 3.0.
