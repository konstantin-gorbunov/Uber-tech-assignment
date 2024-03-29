//
//  DetailViewController.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 11/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel?
    @IBOutlet weak var addressDescriptionLabel: UILabel?
    @IBOutlet weak var bestPhotoImageView: UIImageView?

    var detailItem: Venue? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detailPoint = detailItem?.location, let label = detailDescriptionLabel  {
            let roundedLat = NSString(format: "%.4f", detailPoint.latitude)
            let roundedLon = NSString(format: "%.4f", detailPoint.longitude)
            label.text = "Latitude: \(roundedLat), Longitude: \(roundedLon)"
            
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.navigationBar.topItem?.title = detailItem?.name.capitalized
        }
        addressDescriptionLabel?.text = detailItem?.address
        
        if let bestPhotoUrl = detailItem?.bestPhoto, let imageView = bestPhotoImageView {
            imageView.downloaded(from: bestPhotoUrl)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }
}
