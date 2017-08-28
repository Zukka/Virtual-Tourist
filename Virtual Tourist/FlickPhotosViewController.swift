//
//  FlickPhotosViewController.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 26/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class FlickPhotosViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: Properties
    
    // Core Data
    var sharedObjectContext: NSManagedObjectContext {
        return CoreDataController.sharedInstance().managedObjectContext
    }
   
    var pinSelected = Pin()
    let locationManager = CLLocationManager()
    // MARK: IBOutlet
    @IBOutlet weak var photoMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        photoMapView.delegate = self
        
        dropCurrentPinOnMapView(pinLatitude: pinSelected.latitude, pinLongitude: pinSelected.longitude)
        
        // Create Fetch Request
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let pred = NSPredicate(format: "pin = %@", argumentArray: [pinSelected])
        fr.predicate = pred
        
        do {
            let Photos: [Photo] = try sharedObjectContext.fetch(fr) as! [Photo]
            if Photos.count == 0 {
                
                // Use withPageNumber with -99 value for first call
                
                FlickClient.sharedInstance().getImageFromFlickrBySearch(latidude: pinSelected.latitude, longitude: pinSelected.longitude, withPageNumber: -99, completionHandlerForGetPhotos: { (success, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("Success")
                    }
                })
            }

        } catch {
            print (error.localizedDescription)

        }
    }

    // MARK: MapView func
    
    func dropCurrentPinOnMapView(pinLatitude: Double, pinLongitude: Double) {
        let annotation = MKPointAnnotation()
        
        let location = CLLocationCoordinate2D(latitude: pinLatitude, longitude: pinLongitude)
        let center = location
        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20))
        photoMapView.setRegion(region, animated: true)
        annotation.coordinate = location
        photoMapView.addAnnotation(annotation)


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
