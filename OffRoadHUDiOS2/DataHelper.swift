//
//  DataHelper.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/9/20.
//

import Foundation
import CoreData
import SwiftUI

class DataHelper {
    
    public func printAllSavedLocations() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Location")
        var locations: [NSManagedObject] = []
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        print("Printing all locations found in CoreData database...")
        for location in locations {
            print(createPrintableLocationString(location: location as! Location))
        }
        
        print("Printing complete...")
    }
    
    func createPrintableLocationString(location: Location) -> String {
        let locationString = "latitude: \(location.latitude) longitude: \(location.longitude) speedMS: \(location.speedMS) date: \(location.dateString)"
        
        return locationString
    }
}
