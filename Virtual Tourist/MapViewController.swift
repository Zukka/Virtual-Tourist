//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 24/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: IBOutlet
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK : Properties
    
    var userPosition: CLLocationCoordinate2D!
    var positionManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.positionManager = CLLocationManager()
        positionManager.delegate = self
        positionManager.requestWhenInUseAuthorization()
        positionManager.pausesLocationUpdatesAutomatically = false
        positionManager.startUpdatingLocation()
        
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
        self.userPosition =  CLLocationCoordinate2DMake(prevLatitude, prevLongitude)
        let span = MKCoordinateSpanMake(prevLatitudeDelta, prevLongitudeDelta)
        let region = MKCoordinateRegion(center: userPosition, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // save previous position
        UserDefaults.standard.set(self.mapView.centerCoordinate.latitude, forKey: "PreviousLatitude")
        UserDefaults.standard.set(self.mapView.centerCoordinate.longitude, forKey: "PreviousLongitude")
        UserDefaults.standard.set(self.mapView.region.span.latitudeDelta, forKey: "PreviousLatitudeSpan")
        UserDefaults.standard.set(self.mapView.region.span.longitudeDelta, forKey: "PreviousongitudeSpan")
    }
}

