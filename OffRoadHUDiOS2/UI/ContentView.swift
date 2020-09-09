//
//  ContentView.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/1/20.
//

import SwiftUI
import os.log

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: Class Properties
    
    // Both the Location and Inclinometer instance need to be @State vars so the view updates when they update.
    @State var location: Location?
    @State var inclinometer: Inclinometer?
    
    let labelTextColor = Color(UIColor(named: "labelText") ?? UIColor(red: 255, green: 0, blue: 0, alpha: 1.0))
    
    // MARK: Init Methods
    
    init() {
        // Start up our background services
        LocationService.shared.start()
        AccelerometerService.shared.start()
        //AccelerometerService.shared.start()
    }
    
    // MARK: View
    
    var body: some View {
        VStack(alignment: .center) {
            SpeedometerView(value: (((location?.speedMPH) ?? 0.0)/100))
                .padding(.top, 150.0)
                .frame(height: 200.0)
            Text("\(location?.speedMPH ?? 0.0, specifier: "%.2f") MPH")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(labelTextColor)
                .multilineTextAlignment(.center)
                .padding(.vertical, 50.0)
            HStack(alignment: .center) {
                ZStack {
                    Text("ROLL")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(labelTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 100.0)
                    InclinometerView(value: Double(inclinometer?.rollDegrees ?? 0))
                        .frame(width: 200.0, height: 190.0)
                    
                    Text("\(inclinometer?.rollDegrees ?? 0)°")
                    //Text("\(0.0)°")
                        .padding(.top, 100.0)
                }
                ZStack {
                    Text("PITCH")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(labelTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 100.0)
                    InclinometerView(value: Double(inclinometer?.pitchDegrees ?? 0))
                    //InclinometerView(value: 0.0)
                    Text("\(inclinometer?.pitchDegrees ?? 0)°")
                    //Text("\(0.0)°")
                        .frame(width: 200.0)
                    
                    .padding(.top, 100.0)
                }
            }
            
            Spacer()
            
        }
        .padding()
        // Register for notifications from our LocationService and update the UI accordingly
        .onReceive(NotificationCenter.default.publisher(for: LocationService.getLocationNotificationName())){ obj in
            if let userInfo = obj.userInfo, let location = userInfo["location"] as? Location {
                os_log("Recieved location broadcast in ContentView! Lat: %f Lon: %f Speed: %f", location.latitude, location.longitude, location.speedMS)
                self.location = location
                
            }
        }
        // Register for notifications from our MotionService and update the UI accordingly
        
        .onReceive(NotificationCenter.default.publisher(for: AccelerometerService.getInclinometerNotificationName())){ obj in
            if let userInfo = obj.userInfo, let inclinometer = userInfo["inclinometer"] as? Inclinometer {
                os_log("Recieved incline broadcast in ContentVeiw!")
                self.inclinometer = inclinometer
            }
        }
        
    }
    
    
}

// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
