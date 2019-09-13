//
//  Foursquare.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 12/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import Foundation
import MapKit

class Foursquare {
    
    private enum Constants {
        static let clientId: String = "HXMSGXIEXRDE2PHPXIO2LCIC04CAK1EQEMDIASUJKHM4VFOF"
        static let clientSecret: String = "YBRTMWXXNADTR5PJJQNO4MIFXZ2XAV4INLGA2GDD10J3CIRY"
    }
    
    var session = URLSession.shared
    
    private enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
    }
    
    func searchFoursquare(for location: CLLocationCoordinate2D, completion: @escaping (Result<FoursquareSearchResults>) -> Void) {
        guard let searchURL = foursquareSearchURL(for: location) else {
            completion(Result.error(Error.unknownAPIResponse))
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        session.dataTask(with: searchRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            guard
                let _ = response as? HTTPURLResponse,
                let data = data
                else {
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
            }
            
            do {
                guard
                    let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                    let metaDictionary = resultsDictionary["meta"] as? [String: AnyObject],
                    let code = metaDictionary["code"] as? Int
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                switch (code) {
                case 200:
                    print("Results processed OK")
                default:
                    DispatchQueue.main.async {
                        completion(Result.error(Error.generic))
                    }
                    return
                }
                
                guard
                    let responseContainer = resultsDictionary["response"] as? [String: AnyObject],
                    let venuesContainer = responseContainer["venues"] as? [[String: AnyObject]]
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                
                let foursquareVenue: [FoursquareVenue] = venuesContainer.compactMap { venueObject in
                    guard
                        let venueID = venueObject["id"] as? String,
                        let name = venueObject["name"] as? String,
                        let locationContainer = venueObject["location"] as? [String: AnyObject],
                        let lat = locationContainer["lat"] as? Double,
                        let lng = locationContainer["lng"] as? Double
                        else {
                            return nil
                    }
                    let locationPoint = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    let foursquareVenue = FoursquareVenue(venueID, name, locationPoint)
                    return foursquareVenue
                }
                let searchResults = FoursquareSearchResults(searchLocation: location, searchResults: foursquareVenue)
                DispatchQueue.main.async {
                    completion(Result.results(searchResults))
                }
            } catch {
                completion(Result.error(error))
                return
            }
            }.resume()
    }
    
    private func foursquareSearchURL(for location: CLLocationCoordinate2D) -> URL? {
        let URLString = "https://api.foursquare.com/v2/venues/search?ll=\(location.latitude),\(location.longitude)&v=20190912&query=restaurant&intent=checkin&limit=10&client_id=\(Constants.clientId)&client_secret=\(Constants.clientSecret)"
        return URL(string: URLString)
    }
}
