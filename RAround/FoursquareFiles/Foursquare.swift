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
    
    var session = URLSession.shared
    
    private enum FError: Swift.Error {
        case unknownAPIResponse
        case generic
    }
    
    func search(for location: CLLocationCoordinate2D, completion: @escaping (Result<SearchResults>) -> Void) {
        guard let searchURL = NetworkRouter.getSearch(location).url else {
            completion(Result.error(FError.unknownAPIResponse))
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        requestData(for: searchRequest) { error, dictionary  in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            guard let resultsDictionary = dictionary else {
                return
            }
            guard
                let responseContainer = resultsDictionary["response"] as? [String: AnyObject],
                let venuesContainer = responseContainer["venues"] as? [[String: AnyObject]]
                else {
                    DispatchQueue.main.async {
                        completion(Result.error(FError.unknownAPIResponse))
                    }
                    return
            }
            
            let foursquareVenue: [Venue] = venuesContainer.compactMap { venueObject in
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
                let foursquareVenue = Venue(venueID, name, locationPoint)
                return foursquareVenue
            }
            let searchResults = SearchResults(searchLocation: location, searchResults: foursquareVenue)
            DispatchQueue.main.async {
                completion(Result.results(searchResults))
            }
        }
    }
    
    func askDetails(for venue: Venue, completion: @escaping (Result<Venue>) -> Void) {
        guard let detailsURL = NetworkRouter.getInfo(venue.venueID).url else {
            completion(Result.error(FError.unknownAPIResponse))
            return
        }
        
        let detailsRequest = URLRequest(url: detailsURL)
        
        requestData(for: detailsRequest) { error, dictionary  in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            guard let resultsDictionary = dictionary else {
                return
            }
            guard
                let responseContainer = resultsDictionary["response"] as? [String: AnyObject],
                let venueObject = responseContainer["venue"] as? [String: AnyObject],
                let locationObject = venueObject["location"] as? [String: AnyObject]
                else {
                    DispatchQueue.main.async {
                        completion(Result.error(FError.unknownAPIResponse))
                    }
                    return
            }
            venue.address = locationObject["address"] as? String
            if let bestPhotoObject = venueObject["bestPhoto"] as? [String: AnyObject],
                let prefix = bestPhotoObject["prefix"] as? String,
                let suffix = bestPhotoObject["suffix"] as? String {
                venue.bestPhoto = URL(string: "\(prefix)300x500\(suffix)")
            }
            DispatchQueue.main.async {
                completion(Result.results(venue))
            }
        }
    }
    
    // MARK: - Private
    
    private func requestData(for request: URLRequest, completion: @escaping (Error?, [String: AnyObject]?) -> Void) {
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(error, nil)
                }
                return
            }
            
            guard
                let _ = response as? HTTPURLResponse,
                let data = data
                else {
                    DispatchQueue.main.async {
                        completion(FError.unknownAPIResponse, nil)
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
                            completion(FError.unknownAPIResponse, nil)
                        }
                        return
                }
                switch (code) {
                case 200:
                    print("Results processed OK")
                default:
                    DispatchQueue.main.async {
                        completion(FError.generic, nil)
                    }
                    return
                }
                completion(nil, resultsDictionary)
            } catch {
                completion(error, nil)
                return
            }
            }.resume()
    }
}
