//
//  FlightModules.swift
//  Dji Drone Automation
//
//  Created by Apoorv Malik on 24/04/19.
//  Copyright © 2019 Apoorv Malik. All rights reserved.
//

import UIKit
import DJISDK
import Firebase

class DroneMission: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var referenceFirebase: DatabaseReference!
    var locationFirebase: [[String:Any]] = []
    
    var homePointAnnotations = DJIImageAnnotation(identifier: "homeAnnotation", customImage: UIImage(named: "homePoint")!)
    var aircraftAnnotation = DJIImageAnnotation(identifier: "aircraftAnnotation", customImage: UIImage(named: "aircraft")!)
    var destAnnotation = DJIImageAnnotation(identifier: "destinationAnnotation", customImage: UIImage(named: "waypoint")!)
    
    @IBOutlet weak var flightAltitudeLabel: UILabel!
    @IBOutlet weak var destinationAltitudeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var returnToHomeButton: UIButton!
    @IBOutlet weak var initializeMissionButton: UIButton!
    @IBOutlet weak var getCoordinatesButton: UIButton!
    
    var wayPointAnnotation = [MKPointAnnotation]()
    var aircraftAnnotationView: MKAnnotationView!
    
    var homeCoordinate: CLLocation?
    var destinationCoordinate: CLLocationCoordinate2D?
    
    var droneCoordinate: CLLocationCoordinate2D?
    var droneHeading: Double = 0
    
    var missionStarted: Bool = false
    var distanceRestrictionOverride: Bool = false
    
    let flightController = (DJISDKManager.product() as? DJIAircraft)?.flightController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        //UI Button Setup
        startButton.isEnabled = false
        pauseButton.isEnabled = false
        stopButton.isEnabled = false
        initializeMissionButton.isEnabled = false
        returnToHomeButton.isEnabled = false
        
        flightAltitudeLabel.text = String("20")
        destinationAltitudeLabel.text = String("5")
        
        //Firebase Setup
        referenceFirebase = Database.database().reference()
        
        referenceFirebase.child("users").observe(.value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                    self.locationFirebase.append(snap.value as! [String : String])
                }
            }
        })
        
        // Setting initial view on the map with aircraft's initial position (home coordinate)
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: true)
        let regionRadius: CLLocationDistance = 200
        let location = getDroneCoordinates()
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        homePointAnnotations.coordinate = location.coordinate
        aircraftAnnotation.coordinate = location.coordinate
        
        droneCoordinate = location.coordinate
        homeCoordinate = location
        
        mapView.region = coordinateRegion
        mapView.addAnnotations([self.aircraftAnnotation, self.homePointAnnotations])
        
        
        // Setting the listeners on aircraft's position and heading
        // And updating the aircraft annotation on map view
        if let aircarftLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)  {
            DJISDKManager.keyManager()?.startListeningForChanges(on: aircarftLocationKey, withListener: self) {[unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if (newValue != nil) {
                    let newLocationValue = DJISDKManager.keyManager()?.getValueFor(aircarftLocationKey)?.value as! CLLocation
                    if CLLocationCoordinate2DIsValid(newLocationValue.coordinate) {
                        self.aircraftAnnotation.coordinate = newLocationValue.coordinate
                        self.droneCoordinate = newLocationValue.coordinate
                        self.updateAircraftLocationFirebase(latitude: String(newLocationValue.coordinate.latitude), longitude: String(newLocationValue.coordinate.longitude), heading: String(self.droneHeading))
                        if self.distanceRestrictionOverride {
                            self.flightController?.setHomeLocation(newLocationValue)
                        }
                    }
                }
            }
        }
        
        
        if let aircraftHeadingKey = DJIFlightControllerKey(param: DJIFlightControllerParamCompassHeading) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: aircraftHeadingKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if (newValue != nil) {
                    self.aircraftAnnotation.heading = newValue!.doubleValue
                    self.droneHeading = newValue!.doubleValue
                    if (self.aircraftAnnotationView != nil) {
                        self.aircraftAnnotationView.transform = CGAffineTransform(rotationAngle: CGFloat(self.degreesToRadians(Double(self.aircraftAnnotation.heading))))
                    }
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let imageAnnotation = annotation as! DJIImageAnnotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: imageAnnotation.identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: imageAnnotation.identifier)
        }
        

        annotationView?.image = imageAnnotation.imageDJI
        
        if annotation.isEqual(self.aircraftAnnotation) {
            if annotationView != nil {
                self.aircraftAnnotationView = annotationView!
            }
        }
        
        return annotationView
    }
        
        
        func getDroneCoordinates () -> CLLocation {
            let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
            let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey!)
            let droneLocation = droneLocationValue?.value as! CLLocation
            return droneLocation
        }
        
        func degreesToRadians(_ degrees: Double) -> Double {
            return Double.pi / 180 * degrees
        }
    
    func updateAircraftLocationFirebase(latitude : String, longitude : String, heading : String) {
        let ref = Database.database().reference()
        let loc = ["latitude" : latitude, "longitude" : longitude, "heading" : heading]
        ref.child("livelocation").setValue(loc)
    }
    
    @IBAction func flightAltitudeSlide(_ sender: UISlider) {
        flightAltitudeLabel.text = String(sender.value)
    }
    
    @IBAction func destinationAltitudeSlide(_ sender: UISlider) {
        destinationAltitudeLabel.text = String(sender.value)
    }
}
