//
//  FlickPhotosViewController.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 26/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//



// pick a random page!
//            let pageLimit = min(totalPages, 40)
//            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1

import UIKit
import CoreData
import MapKit

class FlickPhotosViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: IBOutlet
    @IBOutlet weak var photoMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!

    // MARK: Properties
    var flirckPhotos : [Photo]?
    var pinSelected : Pin?
    let locationManager = CLLocationManager()
    
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    // Core Data
    var sharedObjectContext: NSManagedObjectContext {
        return CoreDataController.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonNewCollectionIsEnabled(enabled: false)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        photoMapView.delegate = self
        
        dropCurrentPinOnMapView(pinLatitude: (pinSelected?.latitude)!, pinLongitude: (pinSelected?.longitude)!)
        
        // Set flowLayout 
        setUpFlowLayout()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self

        // Create Fetch Request
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        let pred = NSPredicate(format: "pin == %@", self.pinSelected!)
        fr.predicate = pred
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr as! NSFetchRequest<Photo>, managedObjectContext: sharedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            flirckPhotos = fetchedResultsController.fetchedObjects!
        } catch let error as NSError {
            print("\(error)")
        }
       
    }
    // Manage enabled status of newCollection button
    func buttonNewCollectionIsEnabled (enabled: Bool) {
        newCollectionButton.isEnabled = enabled
    }
    
    // MARK: FlowLayout func
    
    func setUpFlowLayout() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)

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
    
    // MARK: UICollectionViewDataSource
    
    // Return the number of photos from fetchedResultsController
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let numbersOfItems = self.fetchedResultsController.sections![section].numberOfObjects
        return numbersOfItems
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.flickImageViewCell.image = nil
        cell.activityIndicator.startAnimating()
        let flickPhoto = fetchedResultsController.object(at: indexPath) 
        
        if flickPhoto.imageData != nil {
            
            if let image = UIImage(data:flickPhoto.imageData! as Data) {
                cell.activityIndicator.stopAnimating()
                cell.flickImageViewCell.image = image
            }
            buttonNewCollectionIsEnabled(enabled: true)
        } else if flickPhoto.imageURL != nil {
            performUIUpdatesOnMain {
                
                FlickClient.sharedInstance().donloadImageFromURLString(flickPhoto.imageURL!, completionHandler: { (result, error) in
                    if let image = UIImage(data:result! as Data) {
                        cell.activityIndicator.stopAnimating()
                        cell.flickImageViewCell.image = image
                        flickPhoto.imageData = result! as NSData
                        do {
                            try self.sharedObjectContext.save()
                        } catch let error {
                            print(error)
                        }
                        
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                    
                })
            }
        } else {
            print("URL Empty")
        
        }
        return cell
}

    @IBAction func newCollectionPressed(_ sender: Any) {
        buttonNewCollectionIsEnabled(enabled: false)
        let photos = self.fetchedResultsController.fetchedObjects
        for photo in photos! {
            self.sharedObjectContext.delete(photo)
            do {
                try self.sharedObjectContext.save()
            } catch let error {
                print(error)
            }
        }
        
        self.collectionView.reloadData()
        
        // pick a random page!
        let totalPages = pinSelected?.numOfPhotoPages
        let pageLimit = min(totalPages!, 40)
        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
print("\(randomPage) \(totalPages!)")
        
        FlickClient.sharedInstance().getImageFromFlickrBySearch(pin: self.pinSelected, latidude: (self.pinSelected?.latitude)!, longitude: (self.pinSelected?.longitude)!, withPageNumber: randomPage, completionHandlerForGetPhotos: { (pages, error) in
            
            performUIUpdatesOnMain {
                
                if error != nil {
                    print(error!)
                } else {
                    do {
                        try self.fetchedResultsController.performFetch()
                        self.flirckPhotos = self.fetchedResultsController.fetchedObjects!
                    } catch let error as NSError {
                        print("\(error)")
                    }
                    self.collectionView.reloadData()
                    self.buttonNewCollectionIsEnabled(enabled: true)
                }
                
             }
        })

   
}
}
