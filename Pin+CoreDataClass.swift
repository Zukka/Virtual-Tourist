//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 24/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import Foundation
import MapKit
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    public var numOfPhotoPages: Int?
    // MARK: Initializer
    
    // In Swift, superclass initializers are not available to subclasses, so it is necessary to include this initializer and call the superclass' implementation of it.
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(latitude: Double, longitude: Double, title : String, subtitle: String, numOfPhotoPages: Int, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude;
            self.longitude = longitude
            self.title = title
            self.subtitle = subtitle
            self.numOfPhotoPages = 0
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
        
    var sharedContext: NSManagedObjectContext {
        return CoreDataController.sharedInstance().managedObjectContext
        
    }

}
