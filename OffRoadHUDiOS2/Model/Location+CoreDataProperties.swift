//
//  Location+CoreDataProperties.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//
//

import Foundation
import CoreData


extension Location : Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var date: Date
    @NSManaged public var dateString: String
    @NSManaged public var id: UUID
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var speedMS: Double
    
    public var speedMPH: Double {
        return speedMS * 2.23694
    }

}
