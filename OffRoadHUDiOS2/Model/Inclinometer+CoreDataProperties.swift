//
//  Inclinometer+CoreDataProperties.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//
//

import Foundation
import CoreData


extension Inclinometer : Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inclinometer> {
        return NSFetchRequest<Inclinometer>(entityName: "Inclinometer")
    }

    @NSManaged public var id: UUID
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var z: Double
    @NSManaged public var pitchDegrees: Int16
    @NSManaged public var rollDegrees: Int16

}

