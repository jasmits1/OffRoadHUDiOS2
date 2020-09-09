//
//  AccelerometerService.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//

import Foundation
import CoreMotion
import CoreData
import SwiftUI
import os.log

class AccelerometerService: NSObject {
    
    // MARK: Class Properties
    
    // This allows access to AccelerometerService as a singleton class
    static let shared = AccelerometerService()
    private let notificationCenter: NotificationCenter
    let motionManager = CMMotionManager()
    
    // MARK: Init Methods
    
    /**
     Initializes an instance of AccelerometerService. This class is a singletom class used to handle device motion updates.
     
     Note: This init method does not start AccelerometerService. That needs to be done seperately by calling the start() method.
     
     - Parameters:
     - NotificationCenter: An instance of NotificationCenter that is automatically injected.
     
     - Returns: An instance of AccelerometerService.
     */
    init(notificationCenter: NotificationCenter = .default) {
        os_log("Initializing...", log: OSLog.accelerometerService, type: .debug)
        
        self.notificationCenter = notificationCenter
    }
    
    // MARK: Control Methods
    
    /**
     This method is called to start AccelerometerService and initiate device motion updates
     */
    func start() {
        os_log("Starting...", log: OSLog.accelerometerService, type: .debug)
        motionManager.accelerometerUpdateInterval = 1.0 / 30 // 30hz
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            if(error == nil && data != nil) {
                self.processNewAccelerometerData(data!)
                
                
            } else {
                
                os_log("Error starting AccelerometerService:", log: OSLog.accelerometerService, type: .debug)
                print(error.debugDescription)
                return
            }
        }
        
    }
    
    /**
     Handles newly recieved accelerometer data and then posting it for any listeners.
     
     - Parameters:
     - accelerometerData: An instance of CMAccelerometerData containing new accelerometer information.
     */
    func processNewAccelerometerData(_ accelerometerData: CMAccelerometerData) {
        os_log("Handling device accelerometer event...", log: OSLog.accelerometerService, type: .debug)
        // First calculate the pitch and roll degrees
        let x = accelerometerData.acceleration.x * -9.81
        let y = accelerometerData.acceleration.y * -9.81
        let z = accelerometerData.acceleration.z * -9.81
        
        let pitchAndRoll = calculateRollAndPitch(x: x, y: y, z: z)
        let pitch = pitchAndRoll[0].value
        let roll = pitchAndRoll[1].value
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
     
        let newInclinometer = Inclinometer(context: managedObjectContext)
        newInclinometer.id = UUID()
        newInclinometer.x = x
        newInclinometer.y = y
        newInclinometer.z = z
        newInclinometer.pitchDegrees = pitch
        newInclinometer.rollDegrees = roll
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
       
        postNewIncline(newInclinometer)
        
        testCoreDataInsert()
    }
    
    private func testCoreDataInsert() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Inclinometer")
        var inclines: [NSManagedObject] = []
        do {
            inclines = try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        let incline = inclines[inclines.endIndex - 1]
        
        print("Pitch: ")
        print(incline.value(forKeyPath: "pitchDegrees"))
        print("Roll: ")
        print(incline.value(forKeyPath: "rollDegrees"))
    }
    
    private func postNewIncline(_ inclinometer: Inclinometer) {
        os_log("Posting...", log: OSLog.accelerometerService, type: .debug)
        let inlcineData:[String: Inclinometer] = ["inclinometer": inclinometer]
        notificationCenter.post(name: Notification.Name.newAccelerometerDataRecieved, object: nil, userInfo: inlcineData)
    }
    
    /**
     Public accessor to allow other classes to get the Notification.Name needed to register for notifications from AccelerometerService.
     
     - Returns: An instance of Notification.Name containing AccelerometerService's  name.
     */
    public static func getInclinometerNotificationName() -> Notification.Name {
        os_log("Getting notificiation name...", log: OSLog.accelerometerService, type: .debug)
        return Notification.Name.newAccelerometerDataRecieved
    }
}

/**
 Extension containing the name for our Notification broadcast.
 */
extension Notification.Name {
    static var newAccelerometerDataRecieved: Notification.Name {
        return .init(rawValue: "AccelerometerService.newInclineDataRecieved")
    }
}

// MARK: Utility Methods

private func calculateRollAndPitch(x: Double, y: Double, z: Double) -> KeyValuePairs<String, Int16> {
    let pitchAndRollRad = normalizeAccelerometerData(x: x, y: y, z: z)
    let pitchDegrees = convertToDegrees(radians: pitchAndRollRad[0].value, toNearest: 5.0)
    let rollDegrees = convertToDegrees(radians: pitchAndRollRad[1].value, toNearest: 5.0)
    return [
        "Pitch": pitchDegrees, "Roll": rollDegrees]
}

/**
 When new accelerometer data is recieved this method normalizes it to the phone's orientation and scales it to display the information in an understandable fashion.
 */
private func normalizeAccelerometerData(x: Double, y: Double, z: Double) -> KeyValuePairs<String, Double> {
    os_log("Normalizing Accelerometer Data...", log: OSLog.accelerometerService, type: .debug)
    let normOfAccel = sqrt(Double(x * x + y * y + z * z))
    
    // Normalize the accelerometer vector
    let xN = x / normOfAccel
    let yN = y / normOfAccel
    let zN = z / normOfAccel
    
    // Calculate pitch and roll from XYZ values
    var pitch = acos(zN)
    var roll = atan2(xN, yN)
    
    // Scale values for our use
    if(roll > 3.14159) {
        roll = roll - 6.28319
    }
    pitch = pitch - 1.5708
    
    return [
        "Pitch": pitch,
        "Roll": roll]
    
}

/**
 Converts a given value in radians to degrees rounded to the nearest supplied value.
 
 - Parameters:
 - radians: The value in radians to be converted.
 - toNearest: The value the result should be rounded to a multiple of.
 
 - Returns: The converted value in degrees.
 
 */
private func convertToDegrees(radians: Double, toNearest: Double) -> Int16 {
    os_log("Calibrating and rounding pitch...", log: OSLog.accelerometerService, type: .debug)
    guard !(radians.isZero || radians.isNaN) else {
        return 0
    }
    let degrees = Int16(round(toNearest * (((radians * (180 / Double.pi)) / toNearest))))
    
    return degrees
    
}

/**
 Extension defining our OSLog.
 */
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "(Subsystem name unavailable)"
    
    static let accelerometerService = OSLog(subsystem: subsystem, category: "AccelerometerService")
}



