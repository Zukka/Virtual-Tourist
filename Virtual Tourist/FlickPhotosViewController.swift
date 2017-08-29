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
        NotificationCenter.default.addObserver(self, selector: #selector(FlickPhotosViewController.reloadPhotos(_:)), name: NSNotification.Name(rawValue: "PhotoSaved"), object: nil)
        
    }
    
    func reloadPhotos(_ notification: Notification) {
        performUIUpdatesOnMain {
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("\(error)")
            }

             self.collectionView.reloadData()
        }
           
        
    }
    /*  if flirckPhotos?.count == 900 {
     FlickClient.sharedInstance().getImageFromFlickrBySearch(pin: pinSelected, latidude: (pinSelected?.latitude)!, longitude: (pinSelected?.longitude)!, withPageNumber: FlickClient.numbersOfPages, completionHandlerForGetPhotos: { (photosURL, error) in
                performUIUpdatesOnMain {
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        for item in photosURL {
                            let imageURL = URL(string: item)
                            let imageData = try? Data(contentsOf: imageURL!)
                            if let newPhoto = self.pinSelected, let context = self.fetchedResultsController?.managedObjectContext {
                                // Just create a new image and you're done!
                                let _ = Photo(imageData: (imageData as NSData?)!, imageURL: item, pin: newPhoto, context: context)
                               
                                
                                // save context
                                do {
                                    try self.sharedObjectContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }

                            }
                        }
                       // Refresh for dysplay photos
                        do {
                            try self.fetchedResultsController.performFetch()
                            self.flirckPhotos = try self.sharedObjectContext.fetch(fr) as? [Photo]
                        } catch let error as NSError {
                            print("\(error)")
                        }
                        self.collectionView.reloadData()
                    }
                }
            })
        }
        */

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
        print("Number of photos returned from fetchedResultsController #\(numbersOfItems.numberOfObjects)")
        
        return numbersOfItems.numberOfObjects
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        let flickPhoto = fetchedResultsController.object(at: indexPath)
        if let image = UIImage(data:flickPhoto.imageData! as Data) {
            cell.flickImageViewCell.image = image
        }
        return cell
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
