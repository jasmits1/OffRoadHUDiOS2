//
//  GaugeSection.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//

import SwiftUI

/**
 This struct defines one section used in our Speedometer and Inclinometer gauges.
 */
public struct GaugeSection: Identifiable {
    public var id = UUID()
    var color: Color
    var size: Double
    
    public init(color: Color, size: Double) {
        self.color = color
        self.size = size
    }
}


