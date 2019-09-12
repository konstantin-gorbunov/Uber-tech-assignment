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
    
    var detailViewController: DetailViewController? = nil
    var objects = [CLLocationCoordinate2D]()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        let point = MKPointAnnotation()
        point.coordinate = mapView.centerCoordinate
        mapView.addAnnotation(point)

        objects.insert(point.coordinate, at: 0)
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
        guard let locValue = manager.location?.coordinate, let meterResolution = CLLocationDistance(exactly: 600)  else {
            return
        }
        let region = MKCoordinateRegion(center:locValue, latitudinalMeters: meterResolution, longitudinalMeters: meterResolution)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
}
