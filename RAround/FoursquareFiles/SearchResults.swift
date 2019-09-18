//
//  SearchResults.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 12/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import Foundation
import MapKit

struct SearchResults {
    let searchLocation: CLLocationCoordinate2D
    let searchResults: [Venue]
}
