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
    @State var location: LocationBusinessEntity?
    @State var inclinometer: Inclinometer?
    
    @State var showPopup = false
    @State var isTracking = false
    
    let labelTextColor = Color(UIColor(named: "labelText") ?? UIColor(red: 255, green: 0, blue: 0, alpha: 1.0))
    
    // MARK: Init Methods
    
    init() {
        // Start up our background services
//        LocationService.shared.start()
//        AccelerometerService.shared.start()
        //AccelerometerService.shared.start()
    }
    
    // MARK: View
    
    var body: some View {
        ZStack {
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
            Button(action: {
                if(!isTracking) {
                    self.showPopup = true
                } else {
                    TrackingService.shared.stop()
                    isTracking = false
                }
            }, label: {
                if(!isTracking) {
                    Text("Start Tracking")
                } else {
                    Text("Stop Tracking")
                }
            })
           Spacer()
            CustomAlert(showingAlert: $showPopup, isTracking: $isTracking)
                .opacity(showPopup ? 1 : 0)
//            CustomAlert(textEntered: $textEntered, showingAlert: $showPopup)
//                                .opacity(showPopup ? 1 : 0)
        }
            
        }
        .padding()
        // Register for notifications from our LocationService and update the UI accordingly
        .onReceive(NotificationCenter.default.publisher(for: LocationService.getLocationNotificationName())){ obj in
            if let userInfo = obj.userInfo, let location = userInfo["location"] as? LocationBusinessEntity {
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
        .onAppear {
            LocationService.shared.start()
            AccelerometerService.shared.start()
            
        }
        .onDisappear {
            LocationService.shared.stop()
            AccelerometerService.shared.stop()
        }
    }
}

struct CustomAlert: View {
    //@Binding var textEntered: String
    @Binding var showingAlert: Bool
    @Binding var isTracking: Bool
    
    @State var alertLabel = "Enter Route Name"
    @State var text = ""
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
            VStack {
                Text(alertLabel)
                    .font(.title)
                    .foregroundColor(.black)
                
                Divider()
                
                TextField("Route Name", text: $text)
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                
                Divider()
                
                HStack {
                    Button("Begin Route") {
                        if(text.isEmpty) {
                            alertLabel = "Route Name Required"
                        } else {
                        TrackingService.shared.start(routeName: text)
                        isTracking = true
                        print(text)
                        self.showingAlert.toggle()
                        }
                    }
                    Button("Cancel") {
                        self.showingAlert.toggle()
                    }
                }
                .padding(30)
                .padding(.horizontal, 40)
            }
        }
        .frame(width: 300, height: 200)
    }
}


// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
