//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 24/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: IBOutlet
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // move infoView down over the screen for initial view
        infoView.transform = CGAffineTransform(translationX: 0, y: 75)
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
    
    
}

