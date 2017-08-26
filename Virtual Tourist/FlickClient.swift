//
//  FlickClient.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 26/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import UIKit

class FlickClient : NSObject {
    
    // shared session
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    func taskForGETMethod(_ methodParameters: [String: AnyObject], completionHandleforGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask  {
        /* 1. Set the parameters and a random page */
        let parameters = methodParameters
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters as! [String : String]))
        
        // create network request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Check if there is a connection error
            if error != nil {
                completionHandleforGET(nil, error! as NSError)
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandleforGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }

    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: String]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickClient {
        struct Singleton {
            static var sharedInstance = FlickClient()
        }
        return Singleton.sharedInstance
    }
    
}
