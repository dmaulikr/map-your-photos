## About

<i>Map Your Photos</i> utilizes ArcGIS platform to visualize and store geo-referenced pictures from [Flickr](https://www.flickr.com/) public feed.

*Submitted to [Runtime Quartz Hackathon 2016](https://blogs.esri.com/esri/arcgis/2017/01/06/runtime-quartz-hackathon-results/).*

## Features
* Search photos by tag and derive geo-referenced photos from Flickr public feed for the given tag and displays them as  graphics on map.

  <img src="https://cloud.githubusercontent.com/assets/8196343/24078836/f4d2ad4c-0c35-11e7-8b57-1c24e2cab204.png" alt="alt text" width="250" height="400">

* Select one or more graphics on map to display popup view controller, which contains description of the selected photos.

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
