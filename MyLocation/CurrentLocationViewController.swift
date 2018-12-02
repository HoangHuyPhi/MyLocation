//
//  FirstViewController.swift
//  MyLocation
//
//  Created by Phi Hoang Huy on 12/1/18.
//  Copyright © 2018 Phi Hoang Huy. All rights reserved.
//

import UIKit
import CoreLocation
class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
// MARK: - VARIABLES
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    var location : CLLocation?
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        messageLabel.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    // MARK: - FUNCTION OUTLETS
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        // request location data
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
    }
        // if users don't allow to access location data
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
       // Set CurrentLocationViewController to be the delegate of CLLocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    func updateLabels() {
        if let location = location {
        // Use format string instead of String interpolation
            latitudeLabel.text = String(format: "%.8f",
                                        location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f",
                                        location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        } }
    // MARK: - CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        location = newLocation
        updateLabels()
    }
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
}

