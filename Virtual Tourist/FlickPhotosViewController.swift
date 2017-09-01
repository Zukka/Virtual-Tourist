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
        } catch let error as NSError {
            print("\(error)")
        }
        
        // Add notification to observer saved flirck photo
        NotificationCenter.default.addObserver(self, selector: #selector(FlickPhotosViewController.reloadCollectionView(_:)), name: NSNotification.Name(rawValue: "PhotoSaved"), object: nil)
        
    }
    
    func reloadCollectionView(_ notification: Notification) {
        
        
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("\(error)")
            }
            
            self.collectionView.reloadData()
       
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
        
        let numbersOfItems = self.fetchedResultsController.sections![section]
        print(numbersOfItems.numberOfObjects)
        return numbersOfItems.numberOfObjects
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
        } else {
            performUIUpdatesOnMain {
                FlickClient.sharedInstance().donloadImageFromURLString(flickPhoto.imageURL!, photo: flickPhoto, completionHandler: { (success, error) in
               
            })
            }
            
        }

        
        return cell
    }

}
