//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 24/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    // MARK: Initializer
    
    convenience init(latitude: Double, longitude: Double, title : String, subtitle: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude;
            self.longitude = longitude
            self.title = title
            self.subtitle = subtitle
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
