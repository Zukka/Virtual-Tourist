//
//  FlickConvenience.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 26/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import Foundation

extension FlickClient {

    // MARK: GET func

    // input are latitude, longitude and a random page
    func getImageFromFlickrBySearch(latidude: Double, longitude: Double, withPageNumber: Int, completionHandlerForGetPhotos: @escaping (_ result: Bool?, _ error: NSError?) -> Void) {
        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        let parameters: [String: String] = [Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch, Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod, Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey, Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latidude, longitude: longitude), Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL, Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat, Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback, Constants.FlickrParameterKeys.Page: "\(withPageNumber)" ]

        let _ = taskForGETMethod(parameters as [String : AnyObject]) { (results, error) in
            if error != nil {
                completionHandlerForGetPhotos(nil, error as NSError?)
                return
            }
            print(results!)
            // pick a random page!
//            let pageLimit = min(totalPages, 40)
//            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
        }
    }
    
    // bluild BBoxString
    func bboxString(latitude: Double, longitude: Double) -> String {
        let minLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maxLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maxLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
        
    }

}
