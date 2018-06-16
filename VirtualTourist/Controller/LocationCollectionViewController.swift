//
//  LocationCollectionViewController.swift
//  VirtualTourist
//
//  Created by Jason on 6/14/18.
//  Copyright © 2018 jlhoopes.com. All rights reserved.
//
import UIKit
import MapKit
import CoreData

class LocationCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var collectionViewActionButton: UIButton!
    @IBOutlet weak var photoTableView: UICollectionView!
    @IBOutlet weak var locationZoomIn: MKMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<LocationPhoto>!
    var tappedPin: LocationPin!
    
    var savedPhotos: [LocationPhoto] = [LocationPhoto]()
    var photosToDelete: [IndexPath] = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tappedPin.cityName
        //Set the delegates
        photoTableView.delegate = self
        locationZoomIn.delegate = self
        
        //Layout UI
        defaultButtonStyle()
        photoTableView.allowsMultipleSelection = true
        
        //Download Image Data from CoreData
        getImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMapZoom()
        getImages()
        //get photos
        if savedPhotos.count == 0 {
            downloadNewImagesAt(page: 1)
        } else {
            getImages()
        }
    }
    
    //MARK: Map Configuration
    func configureMapZoom() {
        let zoomCoordinates = CLLocationCoordinate2DMake(tappedPin.latitude, tappedPin.longitude)
        let mapSpan = MKCoordinateSpanMake(0.05, 0.05)
        let mapRegion = MKCoordinateRegionMake(zoomCoordinates, mapSpan)
        self.locationZoomIn.setRegion(mapRegion, animated: false)
        
        let coodinates = CLLocationCoordinate2D(latitude: tappedPin.latitude, longitude: tappedPin.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coodinates
        self.locationZoomIn.addAnnotation(annotation)
        locationZoomIn.isUserInteractionEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //MARK: User Experience
    @IBAction func confirmImageSelectionAction(_ sender: Any) {
        if photosToDelete.count >= 1 {
            deleteSelectedPhotos()
        } else if photosToDelete.count == 0 {
            deleteAndGetNewPhotos()
        }
    }
    
    //MARK: Core Functions
    func getImages() {
        let fetchRequest: NSFetchRequest<LocationPhoto> = LocationPhoto.fetchRequest()
        let predicate = NSPredicate(format: "locationPin == %@", tappedPin)
        fetchRequest.predicate = predicate
        let sortDescriptors = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptors]
        
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            savedPhotos = results
        }
    }
    
    func downloadNewImagesAt(page: Int) {
        VirtualTouristClient.shared.getImagesFrom(lat: tappedPin.latitude, long: tappedPin.longitude, pageNumber: page, perPage: nil) { (dictionary, success, string) in
            
            if success {
                
                if dictionary.count == 0 {
                    print("This pin has no images")
                }
                
                //Parse for photo properties
                for photoDict in dictionary {
                    
                    let photo = LocationPhoto(context: self.dataController.viewContext)
                    
                    if let pin = try? self.dataController.viewContext.object(with: self.tappedPin.objectID) {
                        photo.locationPin = pin as? LocationPin
                    }
                    photo.url_m = photoDict["url_m"] as? String
                    photo.id = photoDict["id"] as? String
                    self.savedPhotos.append(photo)
                }
                
                //Reload the View
                DispatchQueue.main.async {
                    self.photoTableView.reloadData()
                }
            }
            try? self.dataController.viewContext.save()
        }
    }
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        
        task.resume()
    }
    
    //Deletes and pulls new images upon user request.
    func deleteAndGetNewPhotos() {
        for photo in savedPhotos {
            dataController.viewContext.delete(photo)
        }
        savedPhotos.removeAll()
        photosToDelete.removeAll()
        
        //Pulls new photos from the next page, then the next page, rather than a random number which might be out of range
        var page = 2
        downloadNewImagesAt(page: page)
        page += 1
        
        try? dataController.viewContext.save()
        DispatchQueue.main.async {
            self.photoTableView.reloadData()
        }
    }
    
    func deleteSelectedPhotos() {
        if photosToDelete.count >= 1 {
            for photo in photosToDelete {
                let index = photo.row
                dataController.viewContext.delete(savedPhotos[index])
                savedPhotos.remove(at: index)
            }
            photoTableView.deleteItems(at: photosToDelete)
            try? dataController.viewContext.save()
            self.photoTableView.reloadData()
            photosToDelete.removeAll()
            defaultButtonStyle()
        }
    }
    
    
    //MARK: Collection View Protocols
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseID = Constants.StoryboardIDs.CellReuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CollectionViewCell
        
        cell.cellImageView.image = UIImage(named: "Square")
        cell.activityIndicator.startAnimating()
        
        for photo in savedPhotos {
            if photo.imageData == nil {
                if let urlString = photo.url_m {
                    
                    downloadImage(imagePath: urlString) { (data, errorString) in
                        photo.imageData = data
                    }
                }
            }
        }
        
        let cellPhoto = savedPhotos[(indexPath as NSIndexPath).row]
        
        //Try showing images from memory
        if let imageData = cellPhoto.imageData {
            cell.cellImageView.image = UIImage(data: imageData)
            cell.activityIndicator.stopAnimating()
        } else {
            //Default to downloading them again
            if let imageUrl = cellPhoto.url_m {
                downloadImage(imagePath: imageUrl) { (data, string) in
                    DispatchQueue.main.async {
                        if let data = data {
                            cell.cellImageView.image = UIImage(data: data)
                            cellPhoto.imageData = data
                            cell.activityIndicator.stopAnimating()
                            try? self.dataController.viewContext.save()
                        }
                    }
                }
            }
        }
        
        try? dataController.viewContext.save()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Toggle the state of the Delete Photos confirmation button
        deleteImagesState()
        photosToDelete.append(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = photosToDelete.index(of: indexPath) {
            photosToDelete.remove(at: index)
        }
        
        //Set the style of the button if a user deselects all of the images they initially selected to delete
        if photosToDelete.isEmpty {
            defaultButtonStyle()
        }
    }
    
    //MARK: UI Configurations
    func defaultButtonStyle() {
        collectionViewActionButton.setTitle("New Collection", for: .normal)
    }
    
    func deleteImagesState() {
        collectionViewActionButton.setTitle("Remove Selected Pictures", for: .normal)
    }
    
}
