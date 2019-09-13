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

    @IBOutlet weak var mapView: MKMapView!
    
    private var objects = [CLLocationCoordinate2D]()
    
    private let locationManager = CLLocationManager()
    private let foursquare = Foursquare()
    
    private var baseLocation: CLLocation? = nil {
        didSet {
            guard let locValue = baseLocation?.coordinate, let resolution = CLLocationDistance(exactly: 600)  else {
                return
            }
            let region = MKCoordinateRegion(center:locValue, latitudinalMeters: resolution, longitudinalMeters: resolution)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            
            foursquare.searchFoursquare(for: locValue) { searchResults in
                switch searchResults {
                case .error(let error) :
                    print("Error Searching: \(error)")
                case .results(let results):
                    print("Found \(results.searchResults.count)")
                    self.addSearchResultData(results)
                }
            }
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
    
    private func addSearchResultData(_ results: FoursquareSearchResults) {
        for venue in results.searchResults {
            if objects.contains(where: { $0.latitude == venue.location.latitude && $0.longitude == venue.location.longitude}) {
                return
            }
            let point = MKPointAnnotation()
            point.coordinate = venue.location
            mapView.addAnnotation(point)
            
            objects.insert(point.coordinate, at: 0)
        }
        print(objects.count)
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let annotation = mapView.selectedAnnotations.first {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = annotation
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

extension MasterViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view.annotation != nil else {
            return
        }
        self.performSegue(withIdentifier: "showDetail", sender: nil)
        view.isSelected = false
    }
}

extension MasterViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = manager.location?.coordinate, baseLocation == nil {
            baseLocation = manager.location
        }
    }
}
