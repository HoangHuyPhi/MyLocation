//
//  MapViewController.swift
//  MyLocation
//
//  Created by Phi Hoang Huy on 1/13/19.
//  Copyright © 2019 Phi Hoang Huy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    var locations = [Location]()
    @IBOutlet weak var MapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName:
                Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { notification in
                    if self.isViewLoaded  {
                    self.updateLocations()
                }
            }
        }
    }
    @IBAction func showLocation() {
        let theRegion = region(for: locations)
        MapView.setRegion(theRegion, animated: true)
    }
    
    @IBAction func showUser(_ sender: Any) {
        let region = MKCoordinateRegion(center: MapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        MapView.setRegion(MapView.regionThatFits(region), animated: true)
    }
    override func viewDidLoad() {
         super.viewDidLoad()
         updateLocations()
        if !locations.isEmpty {
            showLocation()
        }
    }
    @objc func showLocationDetails(_ sender: UIButton) {
         performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination
                as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    // MARK:- Private methods
    func updateLocations() {
        MapView.removeAnnotations(locations)
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        locations = try! managedObjectContext.fetch(fetchRequest)
        MapView.addAnnotations(locations)
    }
    func region(for annotations: [MKAnnotation]) ->
        MKCoordinateRegion {
            let region: MKCoordinateRegion
            switch annotations.count {
            case 0:
                region = MKCoordinateRegion(
                    center: MapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            case 1:
                let annotation = annotations[annotations.count - 1]
                region = MKCoordinateRegion(
                    center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            default:
                var topLeft = CLLocationCoordinate2D(latitude: -90,
                                                     longitude: 180)
                var bottomRight = CLLocationCoordinate2D(latitude: 90,
                                                         longitude: -180)
                for annotation in annotations {
                    topLeft.latitude = max(topLeft.latitude,
                                           annotation.coordinate.latitude)
                    topLeft.longitude = min(topLeft.longitude,
                                            annotation.coordinate.longitude)
                    bottomRight.latitude = min(bottomRight.latitude,
                                               annotation.coordinate.latitude)
                    bottomRight.longitude = max(bottomRight.longitude,
                                                annotation.coordinate.longitude)
                }
                let center = CLLocationCoordinate2D(
                    latitude: topLeft.latitude -
                        (topLeft.latitude - bottomRight.latitude) / 2,
                    longitude: topLeft.longitude -
                        (topLeft.longitude - bottomRight.longitude) / 2)
                let extraSpace = 1.1
                let span = MKCoordinateSpan(
                    latitudeDelta: abs(topLeft.latitude -
                        bottomRight.latitude) * extraSpace,
                    longitudeDelta: abs(topLeft.longitude -
                        bottomRight.longitude) * extraSpace)
                region = MKCoordinateRegion(center: center, span: span)
            }
            return MapView.regionThatFits(region)
    }
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) ->
        MKAnnotationView? {
            // Because MKAnnotation is a protocol, there may be other objects apart from the Location object that want to be annotations on the map. An example is the blue dot that represents the user’s current location.
            guard annotation is Location else {
                return nil
            }
            // This is similar to creating a table view cell. You ask the map view to re-use an annotation view object. If it cannot find a recyclable annotation view, then you create a new one.
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
            if annotationView == nil {
                let pinView = MKPinAnnotationView(annotation: annotation,
            // This sets some properties to configure the look and feel of the annotation view. Previously the pins were red, but you make them green here.
                    reuseIdentifier: identifier)
                pinView.isEnabled = true
                pinView.canShowCallout = true
                pinView.animatesDrop = false
                pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            /*  You create a new UIButton object that looks like a detail disclosure button - i. You use the target-action pattern to hook up the
                button’s “Touch Up Inside” event with a new method showLocationDetails(), and add the button to the annotation view’s accessory view. */
                let rightButton = UIButton(type: .detailDisclosure)
                rightButton.addTarget(self, action: #selector(showLocationDetails),for: .touchUpInside)
                pinView.rightCalloutAccessoryView = rightButton
                annotationView = pinView
            }
            if let annotationView = annotationView {
                annotationView.annotation = annotation
            /* Once the annotation view is constructed and configured, you obtain a reference to that detail disclosure button again and set its tag to the index of the Location object in the locations array. That way, you can find the Location object later in showLocationDetails() when the button is pressed. */
                let button = annotationView.rightCalloutAccessoryView
                    as! UIButton
                if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
    return annotationView
    }
}

