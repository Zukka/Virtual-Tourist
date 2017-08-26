//
//  FlickPhotosViewController.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 26/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import UIKit

class FlickPhotosViewController: UIViewController {

    var flickLatitude = Double()
    var flickLongitude =  Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use withPageNumber with -99 value for first call
        
        FlickClient.sharedInstance().getImageFromFlickrBySearch(latidude: flickLatitude, longitude: flickLongitude, withPageNumber: -99, completionHandlerForGetPhotos: { (success, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Success")
            }
        })

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
