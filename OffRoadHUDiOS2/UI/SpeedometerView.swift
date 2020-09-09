//
//  SpeedometerView.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//

import SwiftUI

public struct SpeedometerView: View {
    
    // MARK: Class Properties
    
    // TODO: Determine proper way to hardcode the angle and sections. Only the value needs to be variable.
    var value: Double
    
    // This variable determines how large the sweep of our gauge will be. (IE: 360.0 would be an entire circle, 90.0 would be a quarter of a circle.
    var angle: Double = 260.0
    
    // These variables hold the color for each section of our speedometer. Each color is definied in the Assets and include both a light and dark varient
    let speedoColor1 = Color(UIColor(named: "speedo1") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    let speedoColor2 = Color(UIColor(named: "speedo2") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    let speedoColor3 = Color(UIColor(named: "speedo3") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    let speedoColor4 = Color(UIColor(named: "speedo4") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    let speedoColor5 = Color(UIColor(named: "speedo5") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    
    // Here is where we define the sections that will make up our speedometer
    lazy var sections: [GaugeSection] = [GaugeSection(color: speedoColor1, size: 0.2),
                                         GaugeSection(color: speedoColor2, size: 0.2),
                                         GaugeSection(color: speedoColor3, size: 0.2),
                                         GaugeSection(color: speedoColor4, size: 0.2),
                                         GaugeSection(color: speedoColor5, size: 0.2)]
    
    func getSections() -> [GaugeSection] {
        var mutableSelf = self
        return mutableSelf.sections
    }
    
    //MARK: Init Methods
    
    /**
     Initializes a new SpeedometerView with the provided parameters.
     
     - Parameters:
     - Value: The value to be displayed by the speedometer.
     
     - Returns: A pretty SpeedometerView displaying the supplied value
     */
    
    
    public init(value: Double) {
        if(value >= 1.0) {
            self.value = value/100
        } else {
            self.value = value
        }
    }
    
    // MARK: Views
    
    /**
     This is where we put all of our elements together as a complete SpeedometerView.
     */
    public var body: some View {
        // 90 to start in south orientation, then add offset to keep gauge symetric
        let startAngle = 90 + (360.0-angle) / 2.0
        
        ZStack {
            let sections = getSections()
            ForEach(sections) { section in
                // Find index of current section to sum up already covered areas in percent
                if let index = sections.firstIndex(where: {$0.id == section.id}) {
                    let alreadyCovered = sections[0..<index].reduce(0) { $0 + $1.size}
                    
                    // 0.001 is a small offset to fill a gap
                    let sectionSize = section.size * (angle / 360.0)// + 0.001
                    let sectionStartAngle = startAngle + alreadyCovered * angle
                    
                    SpeedoGaugeElement(section: section, startAngle: sectionStartAngle, trim:  0...CGFloat(sectionSize))
                    
                    // Add round caps at start and end
                    let capSize:CGFloat = 0.001
                    if index == 0 {
                        SpeedoGaugeElement(section: section, startAngle: sectionStartAngle, trim: 0...capSize)
                    } else if index == sections.count-1 {
                        SpeedoGaugeElement(section: section, startAngle: startAngle + angle, trim: 0...capSize)
                    }
                    
                }
            }
            .frame(height: 500.0)
            NeedleView(angle: angle, value: value)
            
        }
        
        
        
    }
}

/**
 The gauge itself
 */
struct SpeedoGaugeElement: View {
    var section: GaugeSection
    var startAngle: Double
    var trim: ClosedRange<CGFloat>
    
    var body: some View {
        GeometryReader { geometry in
            let lineWidth = geometry.size.width / 10
            
            section.color
                .mask(Circle()
                        .trim(from: trim.lowerBound, to: trim.upperBound)
                        .stroke(style: StrokeStyle(lineWidth: lineWidth))
                        .rotationEffect(Angle(degrees: startAngle))
                        .padding(lineWidth/2)
                )
        }
    }
}


/**
 The needle used to point to the current speed
 */
struct NeedleView: View {
    var angle: Double
    var value: Double = 0.0
    let needleColor = Color(UIColor(named: "needleColor") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    
    
    var body: some View {
        // 90 to start in south orientation, then add offset to keep gauge symetric
        let startAngle = 90 + (360.0-angle) / 2.0
        let needleAngle = startAngle + value * angle
        
        GeometryReader { geometry in
            ZStack
            {
                let rectWidth = geometry.size.width / 2
                let rectHeight = geometry.size.width / 20
                
                Rectangle()
                    .fill(needleColor)
                    .cornerRadius(rectWidth / 2)
                    .frame(width: rectWidth, height: rectHeight)
                    .offset(x: rectWidth / 2)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width / 10)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .padding()
        .rotationEffect(Angle(degrees: needleAngle))
    }
}

// MARK: Previews

struct SpeedometerView_Previews: PreviewProvider {
    
    static var previews: some View {
        let value = 60.0
        
        //SpeedometerView(angle: angle, sections: sections, value: value)
        SpeedometerView(value: value)
            .frame(height: 500.0)
    }
    
    
}




