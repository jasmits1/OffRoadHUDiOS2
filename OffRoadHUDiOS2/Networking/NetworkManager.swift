//
//  NetworkManager.swift
//  OffRoadHUDiOS2
//
//  Created by Jason Smits on 9/8/20.
//

import Foundation

final class NetworkManager {
    
    private let domainUrlString = "http://localhost:3000/"
    
    func fetchLocations(completionHandler: @escaping ([LocationResult]) -> Void) {
        let url = URL(string: domainUrlString + "location/")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error fetching locations: \(error)")
                return;
            }
            
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Error with location request response, unexpected status code: \(response)")
            return
        }
            if let data = data,
               let locationResults = try? JSONDecoder().decode([LocationResult].self, from: data) {
                completionHandler(locationResults ?? [])
            }
        })
        task.resume()
    }
    
    func postLocation(location: LocationBusinessEntity) {
        let parameters: [String: Any] = [
            "latitude"      : location.latitude,
            "longitude"     : location.longitude,
            "speedMS"       : location.speedMS,
            "dateString"    : location.dateString
        ]
        
        let url = URL(string: domainUrlString + "location/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
        
            request.httpBody = httpBody
            request.timeoutInterval = 20
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
    }
    
    func postLocation(location: Location) {
        let parameters: [String: Any] = [
            "latitude"      : location.latitude,
            "longitude"     : location.longitude,
            "speedMS"       : location.speedMS,
            "dateString"    : location.dateString
        ]
        
        let url = URL(string: domainUrlString + "location/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
        
            request.httpBody = httpBody
            request.timeoutInterval = 20
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
    }
    
    
}

//TODO: Don't forget to delete, keeping this so I don't forget how to call to fetch all locations
/**
 func testNetworkCall() {
     os_log("Testing network call: get all locations...", log: OSLog.locationService, type: .debug)
     appDelegate = UIApplication.shared.delegate as! AppDelegate
     managedObjectContext = appDelegate.persistentContainer.viewContext
     NetworkManager().fetchLocations { [self] (locationResult) in
         self.locationResult = locationResult
         for location in locationResult {
             let newLocation = Location(context: managedObjectContext)
             //newLocation.id = UUID(uuidString: location._id!)!
             newLocation.latitude = location.latitude!
             newLocation.longitude = location.longitude!
             newLocation.speedMS = location.speedMS!
             //newLocation.date = DateFormatter().date(from: location.date!)!
             newLocation.dateString = location.dateString!
             
             print("Attempting to add new Location to database with parameters: ")
             print(self.createPrintableLocationString(location: newLocation))
             do {
                 try managedObjectContext.save()
             } catch let error as NSError {
                 print("Could not save new location. \(error), \(error.userInfo)")
             }
         }
     }
 }
 */

