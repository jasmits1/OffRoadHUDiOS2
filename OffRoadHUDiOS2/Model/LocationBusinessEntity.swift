//
//  LocationBusinessEntity.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/9/20.
//

import Foundation
import CoreLocation

class LocationBusinessEntity {
    public var latitude: Double
    public var longitude: Double
    public var speedMS: Double
    public var dateString: String
    public var speedMPH: Double {
        return speedMS * 2.23694
    }
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.speedMS = location.speed
        self.dateString = ISO8601DateFormatter().string(from: location.timestamp)
    }
}
