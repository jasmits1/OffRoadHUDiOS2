//
//  RouteBusinessEntity.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/10/20.
//

import Foundation

class RouteBusinessEntity {
    public var name: String
    public var startDateString: String
    
    init(name: String, startDateString: String) {
        self.name = name
        self.startDateString = startDateString
    }
}
