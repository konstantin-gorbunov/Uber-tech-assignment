//
//  NetworkRouter.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 18/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import MapKit

enum NetworkRouter {
    
    private enum Constants {
        static let scheme: String = "https"
        static let host: String = "api.foursquare.com"
        static let version: String = "20190913"
        static let limit: String = "10"
        static let intent: String = "checkin"
        static let query: String = "restaurant"
        static let clientId: String = "TKWUKMDAEMGAGXXL1MAPT4IJCLJN2VHWLFP34DQFZXUFH5OL"
        static let clientSecret: String = "5MXN3QVUYKINM04WPHXGABVIGKSO0JNP3FY2J1FPOJNYMWTR"
    }
    
    case getSearch(CLLocationCoordinate2D)
    case getInfo(String)
    
    private var parameters: [URLQueryItem] {
        switch self {
        case .getSearch(let location):
            return [URLQueryItem(name: "v", value: Constants.version),
                    URLQueryItem(name: "limit", value: Constants.limit),
                    URLQueryItem(name: "ll", value: "\(location.latitude),\(location.longitude)"),
                    URLQueryItem(name: "intent", value: Constants.intent),
                    URLQueryItem(name: "query", value: Constants.query),
                    URLQueryItem(name: "client_id", value: Constants.clientId),
                    URLQueryItem(name: "client_secret", value: Constants.clientSecret)]
        case .getInfo:
            return [URLQueryItem(name: "v", value: Constants.version),
                    URLQueryItem(name: "client_id", value: Constants.clientId),
                    URLQueryItem(name: "client_secret", value: Constants.clientSecret)]
        }
    }
    
    private var path: String {
        switch self {
        case .getSearch:
            return "/v2/venues/search"
        case .getInfo(let venueID):
            return "/v2/venues/\(venueID)"
        }
    }
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.path = path
        components.queryItems = parameters
        return components.url
    }
}
