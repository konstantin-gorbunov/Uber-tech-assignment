//
//  FoursquareSearchResults.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 12/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import Foundation
import MapKit

struct FoursquareSearchResults {
    let searchLocation: CLLocationCoordinate2D
    let searchResults: [FoursquareVenue]
}
