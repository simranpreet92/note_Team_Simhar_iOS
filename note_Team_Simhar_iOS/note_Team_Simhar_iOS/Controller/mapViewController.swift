//
//  mapViewController.swift
//  note_Team_Simhar_iOS
//
//  Created by Harneet singh on 30/05/21.
//  Copyright © 2021 mohammadkiani. All rights reserved.
//

import UIKit
import MapKit
class mapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isZoomEnabled = true
        mapView.delegate = self
        //   mapView.setRegion(mRegion, animated: true)
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = "you r here"
        //   annotation.coordinate = userCurrentLocation
        mapView.addAnnotation(annotation)
        // Do any additional setup after loading the view.
    }
    

}
