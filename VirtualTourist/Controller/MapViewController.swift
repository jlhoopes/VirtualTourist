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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    var dataController: DataController!
    var mapPins: [LocationPin] = [LocationPin]()
    var fetchedResultsController: NSFetchedResultsController<LocationPin>!
    
    var pinTappedToView: LocationPin?
    
    var editState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //View Defaults
        navigationBar.title = "Virtual Tourist"
        configureMap()
        configureGestureRecognizer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("Latitude = \(lat), Longitude = \(long)")
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
        
        let lat = locationManager.location?.coordinate.latitude
        let lon = locationManager.location?.coordinate.longitude
        
        mapView.delegate = self
        
        let location = CLLocationCoordinate2DMake(lat!, lon!)
        let mapSpan = MKCoordinateSpanMake(25, 25)
        let region = MKCoordinateRegionMake(location,mapSpan)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    //MARK: Location Logic
    func getLocationName(_ location: CLLocationCoordinate2D, completionHandler: @escaping(_ locationName: String?) -> Void) {
        let geocoder = CLGeocoder()
        let mapLat: CLLocationDegrees = location.latitude
        let mapLong: CLLocationDegrees = location.longitude
        let newLocation = CLLocation(latitude: mapLat, longitude: mapLong)
        
        // City Info
        geocoder.reverseGeocodeLocation(newLocation) { (placemark, error) in
            if error == nil {
                if let newLocationString = placemark?[0] {
                    //If no Locality or Country exist, show "Unknown"
                    completionHandler("\(newLocationString.locality ?? "Unknown"), \(newLocationString.country ?? "Unknown")")
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    //MARK: Core Data Protocols
    fileprivate func fetchSavedPins() {
        let fetchRequest: NSFetchRequest<LocationPin> = LocationPin.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptors]
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            mapPins = results
        }
        
        var savedPins: [MKPointAnnotation] = [MKPointAnnotation]()
        for pin in mapPins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = pin.cityName
            savedPins.append(annotation)
        }
        self.mapView.addAnnotations(savedPins)
    }
    
    private let reuseIdentifier = "pin"
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.tintColor = .green                // do whatever customization you want
            annotationView?.canShowCallout = false            // but turn off callout
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editState {
            for pin in mapPins {
                if pin.latitude == view.annotation?.coordinate.latitude {
                    mapView.removeAnnotation(view.annotation!)
                    mapPins.remove(at: mapPins.index(of: pin)!)
                    dataController.viewContext.delete(pin)
                    try? dataController.viewContext.save()
                }
            }
        } else {
                for pin in mapPins {
                    if pin.latitude == view.annotation?.coordinate.latitude {
                        pinTappedToView = pin
                    }
                }
                try? dataController.viewContext.save()
                self.performSegue(withIdentifier: Constants.StoryboardIDs.SegueID, sender: self)
            }
    }
    
    //MARK: Edit State Configuration
    func changeEditState() {
        editState = !editState
        
        if editState == true {
            editPinsButton.title = "Done"
            navigationBar.title = "Tap Pins to Delete"
        } else {
            editPinsButton.title = "Edit"
            navigationBar.title = "Virtual Tourist"
        }
    }
    
    @IBAction func removePins(_ sender: Any) {
        changeEditState()
        try? dataController.viewContext.save()
    }
    
    //MARK: User Experience
    @objc func addMapAnnotation(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let location = press.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            
            let mapPin = LocationPin(context: dataController.viewContext)
            mapPin.creationDate = Date()
            mapPin.latitude = coordinates.latitude
            mapPin.longitude = coordinates.longitude
            
            annotation.coordinate = coordinates
            getLocationName(annotation.coordinate) { (locationName) in
                annotation.title = locationName
                mapPin.cityName = locationName
            }
            
            mapView.addAnnotation(annotation)
            mapPins.append(mapPin)
            try? dataController.viewContext.save()
        }
    }
    
    func configureGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addMapAnnotation(press:)))
        gesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gesture)
    }
}

extension MapViewController {
    //Send the selected Pin to the Photo Collection View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationView = segue.destination as? LocationCollectionViewController {
            locationView.dataController = dataController
            locationView.tappedPin = pinTappedToView
            let backItem = UIBarButtonItem()
            backItem.title = "OK"
            navigationItem.backBarButtonItem = backItem
            try? dataController.viewContext.save()
        }
    }
}
