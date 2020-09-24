//
//  Route+CoreDataProperties.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/10/20.
//
//

import Foundation
import CoreData


extension Route : Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var name: String
    @NSManaged public var startDateString: String

}

