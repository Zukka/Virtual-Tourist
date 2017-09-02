//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 24/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: IBOutlet
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK : Properties
    
    var userPosition: CLLocationCoordinate2D!
    var positionManager: CLLocationManager!
    
    var mapPin :[Pin] = []
    var selectedPin : Pin?
    
    // Core Data
    var sharedObjectContext: NSManagedObjectContext {
        return CoreDataController.sharedInstance().managedObjectContext
    }
    
    var alertView : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the map view delegate
        mapView.delegate = self
                
        preparePositionManager()
        
        addGestureRecognizerToMapView()
        
        // move infoView down over the screen for initial view
        infoView.transform = CGAffineTransform(translationX: 0, y: 75)
        
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            // Retrive previous data
            let previousLatitude = UserDefaults.standard.double(forKey: "PreviousLatitude")
            let previousLongitude = UserDefaults.standard.double(forKey: "PreviousLongitude")
            let previousLatitudeDelta = UserDefaults.standard.double(forKey: "PreviousLatitudeSpan")
            let previousLongitudeDelta = UserDefaults.standard.double(forKey: "PreviousongitudeSpan")
            
            restoreOldMap(prevLatitude: previousLatitude, prevLongitude: previousLongitude, prevLatitudeDelta: previousLatitudeDelta, prevLongitudeDelta: previousLongitudeDelta)
        } else {
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
        }
        
        // Load Pins from CoreData
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            let Pins: [Pin] = try sharedObjectContext.fetch(fr) as! [Pin]
            if Pins.count > 0 {
                appendPinsToMap(Pins: Pins)
            }
        } catch {
            print (error.localizedDescription)
        }
    }

    // MARK: IBAction
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if editButton.title == "Edit" {
            hideInfoView(hide: false)
            renameEditButton(newTitle: "Done")
        } else {
            hideInfoView(hide: true)
            renameEditButton(newTitle: "Edit")
        }
    }
    
    // MARK: func
    
    // func to show and hide the infoView with animation
    func hideInfoView(hide: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
            if hide {
                self.infoView.transform = CGAffineTransform(translationX: 0, y: 75)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: 0)
            } else {
                self.infoView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: -75)
                
            }
        })
    }
    
    func renameEditButton (newTitle: String) {
        
        editButton.title = newTitle
        
    }
    
    // Move map to last position
    func restoreOldMap(prevLatitude: Double, prevLongitude: Double, prevLatitudeDelta: Double, prevLongitudeDelta: Double) {
        self.userPosition = CLLocationCoordinate2DMake(prevLatitude, prevLongitude)
        let span = MKCoordinateSpanMake(prevLatitudeDelta, prevLongitudeDelta)
        let region = MKCoordinateRegion(center: userPosition, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func preparePositionManager() {
        self.positionManager = CLLocationManager()
        positionManager.delegate = self
        positionManager.requestWhenInUseAuthorization()
        positionManager.pausesLocationUpdatesAutomatically = false
        positionManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // save previous position
        UserDefaults.standard.set(self.mapView.centerCoordinate.latitude, forKey: "PreviousLatitude")
        UserDefaults.standard.set(self.mapView.centerCoordinate.longitude, forKey: "PreviousLongitude")
        UserDefaults.standard.set(self.mapView.region.span.latitudeDelta, forKey: "PreviousLatitudeSpan")
        UserDefaults.standard.set(self.mapView.region.span.longitudeDelta, forKey: "PreviousongitudeSpan")
    }

    func addGestureRecognizerToMapView() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        guard editButton.title == "Edit" else {
            showAlertView(message: AlertMessages.NoPinInEditMode)
            return
        }
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            //Now use this coordinate to add annotation on map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Add pin to CoreData
            let newPinAdded = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "", subtitle: "" ,context: sharedObjectContext)
            // save context
            do {
                try sharedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
            // Add pin to MapView
            self.mapPin.append(newPinAdded)
            mapView.addAnnotation(annotation)
            
            // Download Flirck photos immediately
            print(newPinAdded.latitude)
            FlickClient.sharedInstance().getImageFromFlickrBySearch(pin: newPinAdded, latidude: newPinAdded.latitude, longitude: newPinAdded.longitude, withPageNumber: FlickClient.numbersOfPages, completionHandlerForGetPhotos: { (success, error) in
                
                performUIUpdatesOnMain {
                    
                    if error != nil {
                        print(error!)
                    } else {
                        
                        print(success)
                    }
                    
                }
            })
        }
    }
    
    func appendPinsToMap(Pins: [Pin]) {
        for item in Pins {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2DMake(item.latitude, item.longitude)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapPin.append(item)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
  
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        for item in mapPin {
            if item.latitude == view.annotation?.coordinate.latitude && item.longitude == view.annotation?.coordinate.longitude {
                if editButton.title == "Done" {
                    // remove PIN from CoreData
                    sharedObjectContext.delete(item)
                    
                    // Delete Pin from mapView
                    mapView.removeAnnotation(view.annotation!)
                    
                    // save context
                    do {
                        try sharedObjectContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    selectedPin = item
                    print("Pages are : \(String(describing: selectedPin?.numOfPages))")
                    // OPEN photosViewController
                    self.performSegue(withIdentifier: "segueToFlickPhotos", sender: nil)
                }
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = false
        
        return annotationView
    }
    
    // MARK : Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else {
            return
        }
        
        switch segue.identifier! {
        case "segueToFlickPhotos":
            
            // Send the current pin to FlickPhotosViewController
            
            (segue.destination as! FlickPhotosViewController).pinSelected = selectedPin!
            
        default:
            
            break
        }
    }
    
    // MARK: AlertView 
    
    func showAlertView(message: String) {
        
        self.alertView = UIAlertController(title: "Virtual Tourist",
                                                    message: message,
                                                    preferredStyle: .alert)
        // Add action for close alert view
        let action = UIAlertAction(title: "Close", style: UIAlertActionStyle.default,
                                   handler: {(paramAction :UIAlertAction!) in
                                    
        })
        alertView!.addAction(action)
        
        present(alertView!, animated: true, completion: nil)
    }
}

