//
//  CLLocationCoordinate2DExtension.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 18/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D: Equatable {
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
