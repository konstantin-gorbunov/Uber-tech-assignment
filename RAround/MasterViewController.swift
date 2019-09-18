//
//  MasterViewController.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 11/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import UIKit
import MapKit

class MasterViewController: UIViewController {

    private enum Constants {
        static let mapInitialSize: Double = 1000 // in meters
    }
    
    @IBOutlet weak var mapView: MKMapView?
    
    private var objects = [Venue]()
    
    private let locationManager = CLLocationManager()
    private let foursquare = ServiceLayer()
    
    private var baseLocation: CLLocation? = nil {
        didSet {
            setMapRegion()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let annotation = mapView?.selectedAnnotations.first,
                let selectedVenue = objects.first(where: { $0.location == annotation.coordinate }),
                let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController {
                controller.detailItem = selectedVenue
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                foursquare.askDetails(for: selectedVenue) { detailsResults in
                    switch detailsResults {
                    case .error(let error) :
                        print("Error Ask Details: \(error)")
                    case .results(let results):
                        print("Details Received for \(results.name)")
                        // notify detail view controller about changes
                        controller.detailItem = results
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func addSearchResultData(_ results: SearchResults) {
        for venue in results.searchResults {
            if objects.contains(where: { $0.venueID == venue.venueID }) {
                print("Venue with name \(venue.name) was added before.")
                continue
            }
            let point = MKPointAnnotation()
            point.coordinate = venue.location
            mapView?.addAnnotation(point)
            
            objects.insert(venue, at: 0)
        }
    }
    
    private func askFoursquare(_ locValue: CLLocationCoordinate2D) {
        foursquare.search(for: locValue) { searchResults in
            switch searchResults {
            case .error(let error) :
                print("Error Searching: \(error)")
            case .results(let results):
                print("Found \(results.searchResults.count)")
                self.addSearchResultData(results)
            }
        }
    }
    
    private func setMapRegion() {
        guard
            let locValue = baseLocation?.coordinate,
            let mapView = mapView,
            let resolution = CLLocationDistance(exactly: Constants.mapInitialSize)
            else {
                return
        }
        let region = MKCoordinateRegion(center:locValue, latitudinalMeters: resolution, longitudinalMeters: resolution)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
}

extension MasterViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        performSegue(withIdentifier: "showDetail", sender: nil)
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if baseLocation != nil {
            askFoursquare(mapView.centerCoordinate) // should be asked only after initial location was set
        }
    }
}

extension MasterViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = manager.location?.coordinate, baseLocation == nil {
            baseLocation = manager.location
        }
    }
}
