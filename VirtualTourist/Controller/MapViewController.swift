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
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    //var dataController: DataController!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    
    var locManager = CLLocationManager()
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //View Defaults
        navigationBar.title = "Virtual Tourist"
        configureMap()
                //print("jinkies")
    }
    
    var dataController:
    DataController!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("\(lat),\(long)")
        } else {
            print("No coordinates")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: General Configurations
    func configureMap() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        var lat = locationManager.location?.coordinate.latitude
        var lon = locationManager.location?.coordinate.longitude
        //print("this")
        //print(locationManager.location?.coordinate.latitude)

        mapView.delegate = self
        
        //let location = CLLocationCoordinate2DMake(lon!, lat!)
        let location = CLLocationCoordinate2DMake(25, 35)
        let mapSpan = MKCoordinateSpanMake(25, 25)
        let region = MKCoordinateRegionMake(location,mapSpan)
        self.mapView.setRegion(region, animated: true)
        
    }
}
