//
//  RAroundTests.swift
//  RAroundTests
//
//  Created by Kostiantyn Gorbunov on 11/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import XCTest
import MapKit
@testable import RAround

class RAroundTests: XCTestCase {

    private let foursquare = Foursquare()
    
    func testAskWithExpectedURLHostAndPath() {
        let mockURLSession  = MockURLSession(data: nil, urlResponse: nil, error: nil)
        foursquare.session = mockURLSession
        let locCoords = CLLocationCoordinate2D(latitude: 54, longitude: 5)
        foursquare.search(for: locCoords) { result in }
        XCTAssertEqual(mockURLSession.cachedUrl?.host, "api.foursquare.com")
        XCTAssertEqual(mockURLSession.cachedUrl?.path, "/v2/venues/search")
    }

    func testAskReturnsError() {
        let mockURLSession  = MockURLSession(data: nil, urlResponse: nil, error: nil)
        foursquare.session = mockURLSession
        let expect = expectation(description: "error result")
        var searchResults: Result<SearchResults>?
        let locCoords = CLLocationCoordinate2D(latitude: 54, longitude: 5)
        foursquare.search(for: locCoords) { result in
            searchResults = result
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(true)
            case .results(_):
                XCTAssertTrue(false)
            }
        }
    }
    
    func testAskParsedAndError() {
        let jsonData = "{\"meta\":{\"code\":400,\"errorType\":\"invalid_auth\",\"errorDetail\":\"Missing access credentials. See for details.\",\"requestId\":\"5d7bbea4bcbf7a002c628e72\"},\"response\":{}}".data(using: .utf8)
        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: HTTPURLResponse(), error: nil)
        foursquare.session = mockURLSession
        let expect = expectation(description: "error result")
        var searchResults: Result<SearchResults>?
        let locCoords = CLLocationCoordinate2D(latitude: 54, longitude: 5)
        foursquare.search(for: locCoords) { result in
            searchResults = result
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(true)
            case .results(_):
                XCTAssertTrue(false)
            }
        }
    }
    
    func testAskParsedAndEmpty() {
        let jsonData = "{\"meta\":{\"code\":200,\"requestId\":\"5d7bc0670d2be7002c7f7e6d\"},\"response\":{\"venues\":[]}}".data(using: .utf8)
        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: HTTPURLResponse(), error: nil)
        foursquare.session = mockURLSession
        let expect = expectation(description: "error result")
        var searchResults: Result<SearchResults>?
        let locCoords = CLLocationCoordinate2D(latitude: 54, longitude: 5)
        foursquare.search(for: locCoords) { result in
            searchResults = result
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(false)
            case .results(let results):
                XCTAssertTrue(results.searchResults.count == 0)
            }
        }
    }
    
    func testAskParsedAndOneResult() {
        let venueID = "4bb8ee93cf2fc9b69a0aa002"
        let name = "Restaurant Piripi"
        let jsonData = "{\"meta\":{\"code\":200,\"requestId\":\"5d7bc0670d2be7002c7f7e6d\"},\"response\":{\"venues\":[{\"id\":\"\(venueID)\",\"name\":\"\(name)\",\"location\":{\"address\":\"Kerkstraat\",\"lat\":52.37209946910166,\"lng\":4.527905869624663,\"labeledLatLngs\":[{\"label\":\"display\",\"lat\":52.37209946910166,\"lng\":4.527905869624663}],\"distance\":386,\"cc\":\"NL\",\"city\":\"Zandvoort\",\"state\":\"North Holland\",\"country\":\"Netherlands\",\"formattedAddress\":[\"Kerkstraat\",\"Zandvoort\",\"Netherlands\"]},\"categories\":[{\"id\":\"4bf58dd8d48988d1db931735\",\"name\":\"Tapas Restaurant\",\"pluralName\":\"Tapas Restaurants\",\"shortName\":\"Tapas\",\"icon\":{\"prefix\":\"https:\",\"suffix\":\".png\"},\"primary\":true}],\"referralId\":\"v-1568391271\",\"hasPerk\":false}]}}".data(using: .utf8)
        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: HTTPURLResponse(), error: nil)
        foursquare.session = mockURLSession
        let expect = expectation(description: "error result")
        var searchResults: Result<SearchResults>?
        let locCoords = CLLocationCoordinate2D(latitude: 54, longitude: 5)
        foursquare.search(for: locCoords) { result in
            searchResults = result
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(false)
            case .results(let results):
                XCTAssertTrue(results.searchResults.count == 1)
                XCTAssertTrue(results.searchResults.first?.venueID == venueID)
                XCTAssertTrue(results.searchResults.first?.name == name)
            }
        }
    }
    
    func testAskParsedAndTwoResult() {
        let venueIdFirst = "4bb8ee93cf2fc9b69a0aa002"
        let nameFirst = "Restaurant Piripi"
        let venueIdSecond = "57815774498e5356bc7095f4"
        let nameSecond = "Buddha beach restaurant"
        let jsonData = "{\"meta\":{\"code\":200,\"requestId\":\"5d7bc2f7787dba0030749518\"},\"response\":{\"venues\":[{\"id\":\"\(venueIdFirst)\",\"name\":\"\(nameFirst)\",\"location\":{\"address\":\"Kerkstraat\",\"lat\":52.37209946910166,\"lng\":4.527905869624663,\"labeledLatLngs\":[{\"label\":\"display\",\"lat\":52.37209946910166,\"lng\":4.527905869624663}],\"distance\":386,\"cc\":\"NL\",\"city\":\"Zandvoort\",\"state\":\"North Holland\",\"country\":\"Netherlands\",\"formattedAddress\":[\"Kerkstraat\",\"Zandvoort\",\"Netherlands\"]},\"categories\":[{\"id\":\"4bf58dd8d48988d1db931735\",\"name\":\"Tapas Restaurant\",\"pluralName\":\"Tapas Restaurants\",\"shortName\":\"Tapas\",\"icon\":{\"prefix\":\"https\",\"suffix\":\".png\"},\"primary\":true}],\"referralId\":\"v-1568391928\",\"hasPerk\":false},{\"id\":\"\(venueIdSecond)\",\"name\":\"\(nameSecond)\",\"location\":{\"lat\":52.380007,\"lng\":4.528971,\"labeledLatLngs\":[{\"label\":\"display\",\"lat\":52.380007,\"lng\":4.528971}],\"distance\":1025,\"cc\":\"NL\",\"country\":\"Netherlands\",\"formattedAddress\":[\"Netherlands\"]},\"categories\":[{\"id\":\"4bf58dd8d48988d1c4941735\",\"name\":\"Restaurant\",\"pluralName\":\"Restaurants\",\"shortName\":\"Restaurant\",\"icon\":{\"prefix\":\"https\",\"suffix\":\".png\"},\"primary\":true}],\"referralId\":\"v-1568391928\",\"hasPerk\":false}]}}".data(using: .utf8)
        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: HTTPURLResponse(), error: nil)
        foursquare.session = mockURLSession
        let expect = expectation(description: "error result")
        var searchResults: Result<SearchResults>?
        let locCoords = CLLocationCoordinate2D(latitude: 54, longitude: 5)
        foursquare.search(for: locCoords) { result in
            searchResults = result
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssert(false)
            case .results(let results):
                XCTAssertTrue(results.searchResults.count == 2)
                XCTAssertTrue(results.searchResults.first?.venueID == venueIdFirst)
                XCTAssertTrue(results.searchResults.first?.name == nameFirst)
                
                let secondResult = results.searchResults[1]
                XCTAssertTrue(secondResult.venueID == venueIdSecond)
                XCTAssertTrue(secondResult.name == nameSecond)
            }
        }
    }
}

class MockURLSession: URLSession {
    
    var cachedUrl: URL?
    private let mockTask: MockTask
    
    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        mockTask = MockTask(data: data, urlResponse: urlResponse, error:
            error)
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.cachedUrl = request.url
        mockTask.completionHandler = completionHandler
        return mockTask
    }
}

class MockTask: URLSessionDataTask {
    
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    private let data: Data?
    private let urlResponse: URLResponse?
    private let internalError: Error?
    
    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data
        self.urlResponse = urlResponse
        internalError = error
    }
    override func resume() {
        DispatchQueue.main.async {
            if let hadler = self.completionHandler {
                hadler(self.data, self.urlResponse, self.internalError)
            }
        }
    }
}
