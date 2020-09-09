//
//  InclinometerView.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//

import SwiftUI

struct InclinometerView: View {
    
    // MARK: Class Properties
    
    // TODO: Determine proper way to hardcode the angle and sections. Only the value needs to be variable.
    var value: Double
    
    // This variable defines the total sweep of our gauge. As the middle is zero this means the maximum and minimum values will be half of this number.
    var scaleSize: Double = 60.0
    
    // These variables hold the color for each section of our speedometer. Each color is definied in the Assets and include both a light and dark varient
    let gaugeColor1 = Color(UIColor(named: "incline1") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    let gaugeColor2 = Color(UIColor(named: "incline2") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    //let defaultColor = Color(red: 0, green: 0, blue: 0, opacity: 0.2)
   
    // Here is where define the sections that will make up our gauge
    lazy var sections: [GaugeSection] = [GaugeSection(color: gaugeColor1, size: 0.166),
                                         GaugeSection(color: gaugeColor2, size: 0.166),
                                         GaugeSection(color: gaugeColor1, size: 0.166),
                                         GaugeSection(color:  gaugeColor2, size: 0.166),
                                         GaugeSection(color: gaugeColor1, size: 0.166),
                                         GaugeSection(color:  gaugeColor2, size: 0.166)]

    // This allows us to use our sections in the our struct despite being a lazy var
    // Note: our sections need to be lazy so they can utilize our UIColors
    func getSections() -> [GaugeSection] {
        var mutableSelf = self
        return mutableSelf.sections
    }
    
    // MARK: Init Methods
    
    /**
     Initializes a new InclinometerView with the provided value.
     
     - Parameters:
        - Value: The value to be displayed by the inlinometer.
     
     - Returns: A pretty InclinometerView displaying the supplied value.
     */
    public init(value: Double) {
        self.value = value
    }
    
    // MARK: Views
    
    /**
     This is where we put all our elements together as a complete InclinometerView.
     */
    var body: some View {
        let leftStartAngle = 150
        let rightStartAngle = 330
        
        ZStack {
            let sections = getSections()
            // Set up the left scale
            ForEach(sections) { section in
                // Find index of current section to sum up already covered areas in percent
                if let index = sections.firstIndex(where: {$0.id == section.id}) {
                    let alreadyCovered = sections[0..<index].reduce(0) { $0 + $1.size}
                    
                    // 0.001 is a small offset to fill a gap
                    let sectionSize = section.size * (scaleSize / 360.0)// + 0.001
                    let sectionStartAngle = Double(leftStartAngle) + alreadyCovered * scaleSize
                    
                    InclinometerGaugeElement(section: section, startAngle: sectionStartAngle, trim:  0...CGFloat(sectionSize))
                }
            }
            
            // Set up the right scale
            ForEach(sections) { section in
                // Find index of current section to sum up already covered areas in percent
                if let index = sections.firstIndex(where: {$0.id == section.id}) {
                    let alreadyCovered = sections[0..<index].reduce(0) { $0 + $1.size}
                    
                    // 0.001 is a small offset to fill a gap
                    let sectionSize = section.size * (scaleSize / 360.0)// + 0.001
                    let sectionStartAngle = Double(rightStartAngle) + alreadyCovered * scaleSize
                    
                    InclinometerGaugeElement(section: section, startAngle: sectionStartAngle, trim:  0...CGFloat(sectionSize))
                }
            }
            InclineNeedleView(angle: scaleSize, value: value)
        }
    }
}

/**
 This is the gauge element we use as a scale for our InclinometerView
 */
struct InclinometerGaugeElement: View {
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
 The needle that is used to point to the current incline on the InclinometerView.
 */
struct InclineNeedleView: View {
    var angle: Double
    var value: Double = 0.0
    let needleColor = Color(UIColor(named: "needleColor") ?? UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1))
    
    var body: some View {
        // 90 to start in south orientation, then add offset to keep gauge symetric
        let startAngle = 180.0
        let needleAngle = startAngle + value
        
        // Left needle
        GeometryReader { geometry in
            ZStack
            {
                let rectWidth = geometry.size.width / 2
                let rectHeight = geometry.size.width / 20
                
                Rectangle()
                    //.fill(Color.black.opacity(0.8))
                    .fill(needleColor)
                    .cornerRadius(rectWidth / 2)
                    .frame(width: rectWidth, height: rectHeight)
                    .offset(x: rectWidth / 2)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width / 14)
                    
                    
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .padding()
        .rotationEffect(Angle(degrees: needleAngle))
        
        // right needle
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
                    .frame(width: geometry.size.width / 14)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .padding()
        .rotationEffect(Angle(degrees: needleAngle+180))
        
    }
}

// MARK: Previews

struct InclinometerView_Previews: PreviewProvider {
    static var previews: some View {
        let value = 20.0
        InclinometerView(value: value)
            .preferredColorScheme(.light)
    }
}


