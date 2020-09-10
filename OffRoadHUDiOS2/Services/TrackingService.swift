//
//  TrackingService.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/9/20.
//

import Foundation
import SwiftUI
import os.log

class TrackingService: NSObject {
    
    static let shared = TrackingService()
    
    func start() {
        os_log("Starting...", log: OSLog.trackingService, type: .debug)
        NotificationCenter.default.addObserver(self, selector: #selector(saveNewLocation), name: LocationService.getLocationNotificationName(), object: nil)
    }
    
    func start(routeName: String) {
        os_log("Starting with route name %@...", log: OSLog.trackingService, type: .debug, routeName)
        NotificationCenter.default.addObserver(self, selector: #selector(saveNewLocation), name: LocationService.getLocationNotificationName(), object: nil)
    }
    
    func stop() {
        os_log("Stopping...", log: OSLog.trackingService, type: .debug)
        NotificationCenter.default.removeObserver(self, name: LocationService.getLocationNotificationName(), object: nil)
    }
    
    @objc private func saveNewLocation(_ notification: Notification) {
        print("Saving new location...")
        if let userInfo = notification.userInfo, let location = userInfo["location"] as? LocationBusinessEntity {
            os_log("Recieved location broadcast in TrackingService! Lat: %f Lon: %f Speed: %f", location.latitude, location.longitude, location.speedMS)
            saveLocationToCoreData(location)
        }
    }
    
    private func saveLocationToCoreData(_ location: LocationBusinessEntity) {
        DataHelper().printAllSavedLocations()
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        let newLocation = Location(context: managedObjectContext)
        newLocation.latitude = location.latitude
        newLocation.longitude = location.longitude
        newLocation.speedMS = location.speedMS
        newLocation.dateString = location.dateString
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

/**
 Extension defining our OSLog.
 */
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "(Subsystem name unavailable)"
    
    static let trackingService = OSLog(subsystem: subsystem, category: "TrackingService")
}
