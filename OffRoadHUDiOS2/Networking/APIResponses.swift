//
//  APIResponses.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/8/20.
//

import Foundation

struct LocationResult: Codable {
    let _id: String?
    let latitude: Double?
    let longitude: Double?
    let speedMS: Double?
    let dateString: String?
}
