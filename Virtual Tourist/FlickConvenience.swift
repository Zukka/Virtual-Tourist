//
//  FlickConvenience.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 26/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import Foundation
import CoreData

extension FlickClient {
    
    // Core Data
    var sharedObjectContext: NSManagedObjectContext {
        return CoreDataController.sharedInstance().managedObjectContext
    }
    
    // MARK: GET func
    
    // input are PIN, latitude, longitude and a random page
    func getImageFromFlickrBySearch(pin: Pin?, latidude: Double, longitude: Double, withPageNumber: Int, completionHandlerForGetPhotos: @escaping (_ pages: Int, _ error: NSError?) -> Void) {
        
        // Using 'Constants.FlickrParameterKeys.PerPages' parameter I get custom Photos per page, in my case I use 21 for page
        var parameters: [String: AnyObject] = [Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch as AnyObject, Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod as AnyObject, Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey as AnyObject, Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latidude, longitude: longitude) as AnyObject, Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL as AnyObject, Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat as AnyObject, Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback as AnyObject, Constants.FlickrParameterKeys.PerPages: Constants.FlickrParameterValues.PerPages as AnyObject]
        
        if withPageNumber != -99 {
            parameters[Constants.FlickrParameterKeys.Page] = "\(withPageNumber)" as AnyObject
        } else {
            parameters[Constants.FlickrParameterKeys.Page] = Constants.FlickrParameterValues.Page as AnyObject
        }
        let _ = taskForGETMethod(parameters as [String : AnyObject]) { (results, error) in
            if error != nil {
                completionHandlerForGetPhotos(0, error as NSError?)
                return
            }
            let photosDictionary = results?[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject]
            if let photosArray = photosDictionary?[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] {
                let numOfPhotoPages = (photosDictionary?[Constants.FlickrResponseKeys.Pages] as? Int)!
                pin?.numOfPages = Int64(numOfPhotoPages)
                if photosArray.count > 0 {
                    for i: Int in 0 ..< photosArray.count {
                        let photoDictionary = photosArray[i] as [String: AnyObject]
                        let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String
                        print(imageUrlString!)
                        
                        let newPhoto = Photo(imageURL: imageUrlString!, pin: pin!, context: self.sharedObjectContext)
                        newPhoto.pin = pin!
                        do {
                            try self.sharedObjectContext.save()
                        } catch let error {
                            print(error)
                        }
                    }
                    completionHandlerForGetPhotos(numOfPhotoPages, nil)
                }
            }
        }
    }
    
    func donloadImageFromURLString(_ urlString: String, completionHandler: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        
        let imageURL = URL(string: urlString)
        let imageData = try? Data(contentsOf: imageURL!)
        if imageData != nil {
            completionHandler(imageData,nil)
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
