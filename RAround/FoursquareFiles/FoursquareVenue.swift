//
//  FoursquareVenue.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 12/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import Foundation
import MapKit

class FoursquareVenue {
    
    let venueID: String
    let name: String
    let location: CLLocationCoordinate2D
    var address: String?
    var bestPhoto: URL?
    
    init (_ venueID: String, _ name: String, _ location: CLLocationCoordinate2D) {
        self.venueID = venueID
        self.name = name
        self.location = location
    }
}
