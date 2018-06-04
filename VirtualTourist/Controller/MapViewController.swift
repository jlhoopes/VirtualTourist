//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by user140243 on 6/3/18.
//  Copyright © 2018 jlhoopes.com. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    //var dataController: DataController!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //View Defaults
        navigationBar.title = "Virtual Tourist"
    }
    
    var dataController:
    DataController!
    
    //MARK: General Configurations
    func configureMap() {
        mapView.delegate = self
        let location = CLLocationCoordinate2DMake(35, 139)
        let mapSpan = MKCoordinateSpanMake(25, 25)
        let region = MKCoordinateRegionMake(location,mapSpan)
        self.mapView.setRegion(region, animated: true)
    }
}
