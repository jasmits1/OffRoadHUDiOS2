//
//  LocationServices.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//

import CoreData
import CoreLocation
import Foundation
import SwiftUI
import os.log

class LocationService: NSObject, CLLocationManagerDelegate {

    // MARK: Class Properties
    
  
    
    // This allows access to LocationService as a singleton class
    static let shared = LocationService()
    
    let locationManager: CLLocationManager
    static let geoCoder = CLGeocoder()
    private let notificationCenter: NotificationCenter
    
    private var locationResult: [LocationResult]?
    
    var appDelegate: AppDelegate!
    var managedObjectContext: NSManagedObjectContext!
    
    /**
     Creates a DateFormatter to correctly format the date.
     */
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    
    // MARK: Init Methods
    
    /**
     Initializes an instance of LocationService. This class is a singleton used to interact with CLLocationManager and is soley responsible for tracking the user's location.
     Note: This init method does not start LocationService. That needs to be done seperately by calling the start() method.
     
     - Parameters:
     - NotificationCenter: An instance of NotificationCenter that is automatically injected.
     
     - Returns: An instance of LocationService.
     */
    init(notificationCenter: NotificationCenter = .default) {
        os_log("Initiating...", log: OSLog.locationService, type: .info)
        
        locationManager = CLLocationManager()
        self.notificationCenter = notificationCenter
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    
    // MARK: Control Methods
    
    /**
     This method is used to start LocationService and initiate location updates.
     */
    func start() {
        os_log("Starting...", log: OSLog.locationService, type: .debug)
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        os_log("Started successfully!", log: OSLog.locationService, type: .debug)
        
        //NetworkManager().postLocation()
        //testNetworkCall()
    }
    
    func stop() {
        os_log("Stopping...", log: OSLog.locationService, type: .debug)
        locationManager.stopUpdatingLocation()
        os_log("Stopped Successfully!", log: OSLog.locationService, type: .debug)
    }
    
    // TODO: Add a stop?
    
    
    
    
    
    // MARK: CLLocationManagerDelegate Methods
    
    /**
     This method is used by CLLocationManager to notify the delegate(this class) that new location data is available and then handle the new location data. This class is only called by the CLLocationManager object and should never be called directly.
     */
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        os_log("Recieved new data from location manager...", log: OSLog.locationService, type: .debug)
        // Discard all locations except the first
        guard let location = locations.first else {
            return
        }
        
        //processNewLocationData(location)
        postNewLocation(location)
        
    }
    
    // MARK: Public and Private Utility Methods
    
    /**
     This method is responsible for posting new location information for any listeners
     
     - Parameters:
     - location: The Location to be posted.
     */
    private func postNewLocation(_ location: CLLocation) {
        os_log("Posting...", log: OSLog.locationService, type: .debug)
        let newLocation = LocationBusinessEntity(location: location)
        //NetworkManager().postLocation(location: newLocation)
        let locationData:[String: LocationBusinessEntity] = ["location": newLocation]
        notificationCenter.post(name: Notification.Name.newLocationRecieved, object: nil, userInfo: locationData)
    }
    
    /**
     This method is responsible for posting new location information for any listeners
     
     - Parameters:
     - location: The Location to be posted.
     */
    private func postNewLocation(_ location: Location) {
        os_log("Posting...", log: OSLog.locationService, type: .debug)
        NetworkManager().postLocation(location: location)
        let locationData:[String: Location] = ["location": location]
        notificationCenter.post(name: Notification.Name.newLocationRecieved, object: nil, userInfo: locationData)
    }
    
    /**
     Public accessor to allow other classes to get the Notification.Name needed to register for notifications from LocationService.
     
     - Returns: An instance of Notification.Name containing LocationService's name.
     */
    public static func getLocationNotificationName() -> Notification.Name {
        os_log("Getting notification name...", log: OSLog.locationService, type: .debug)
        return Notification.Name.newLocationRecieved
    }
    
}

/**
 Extension containing the name for our Notification broadcast.
 */
extension Notification.Name {
    static var newLocationRecieved: Notification.Name {
        return .init(rawValue: "Location.newLocationRecieved")
    }
}

/**
 Extension defining our OSLog.
 */
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "(Subsystem name unavailable)"
    
    static let locationService = OSLog(subsystem: subsystem, category: "LocationService")
}





