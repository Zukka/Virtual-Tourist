//
//  CoreDataController.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 24/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataController {
    static let shared = CoreDataController()
    
    private var context: NSManagedObjectContext
    
    private init() {
        let application = UIApplication.shared.delegate as! AppDelegate
        self.context = application.persistentContainer.viewContext
    }
    
    func addPin(latitude: Double, longitude: Double) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: self.context)
        
        let newPin = Pin(entity: entity!, insertInto: self.context)
        newPin.latitude = latitude
        newPin.longitude = longitude
        // I think to add a geocoding ad save more information on the pin
        newPin.title = ""
        newPin.subtitle = ""
        
        // Il metodo save() è passibile ad eccezione, quindi deve essere inglobato in un controllo di tipo do-try-catch
        do {
            try self.context.save()
        } catch let error {
            print("[CDC] Save in memory fail.")
            print("Error: \n \(error) \n")
            return false
        }
        
        print("[CDC] save success.")
        return true
    }
    
    func loadAllPin() ->[Pin]  {
        
        let request: NSFetchRequest<Pin> = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        print("[CDC] Recupero tutti i libri dal context ")
        
        request.returnsObjectsAsFaults = false
        
        let pins = self.loadPinsFromFetchRequest(request: request)
        return pins
    }
    
    
    private func loadPinsFromFetchRequest(request: NSFetchRequest<Pin>) -> [Pin] {
        var array = [Pin]()
        do {
            array = try self.context.fetch(request)
            
            guard array.count > 0 else {print("[CDC] No Elements in CoreData "); return []}
            
            for x in array {
                print("[CDC] Lat \(x.latitude) - Lon \(x.longitude)")
            }
            
        } catch let error {
            print("[CDC] FetchRequest fail")
            print("Error: \(error.localizedDescription)")
        }
        
        return array
    }

}
