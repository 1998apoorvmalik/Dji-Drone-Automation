//
//  AutomatedMission.swift
//  Dji Drone Automation
//
//  Created by Apoorv Malik on 24/04/19.
//  Copyright © 2019 Apoorv Malik. All rights reserved.
//

import UIKit
import DJISDK

extension DroneMission {
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        if missionStarted == false {
            missionStarted = true
            startButton.setTitle("Resume", for: .normal)
            startButton.isEnabled = false
            pauseButton.isEnabled = true
            stopButton.isEnabled = true
            returnToHomeButton.isEnabled = true
            DJISDKManager.missionControl()?.startTimeline()
            return
        }

        if DJISDKManager.missionControl()!.isTimelinePaused {
            DJISDKManager.missionControl()?.resumeTimeline()
            pauseButton.isEnabled = true
            startButton.isEnabled = false
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        if DJISDKManager.missionControl()!.isTimelineRunning {
            startButton.isEnabled = true
            DJISDKManager.missionControl()?.pauseTimeline()
            pauseButton.isEnabled = false
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        DJISDKManager.missionControl()?.stopTimeline()
        getCoordinatesButton.isEnabled = true
    }
    
    @IBAction func corrButtonPressed(_ sender: UIButton) {
        getCoordinatesFirebase()
        initializeMissionButton.isEnabled = true
    }
    
    @IBAction func initializeMissionPressed(_ sender: Any) {
        initializeMission()
        getCoordinatesButton.isEnabled = false
        initializeMissionButton.isEnabled = false
    }
    
    @IBAction func RTHButtonPressed(_ sender: UIButton) {
        returnToHome()
        returnToHomeButton.isEnabled = false
        startButton.isEnabled = false
        pauseButton.isEnabled = false
    }
    
    
    func initializeMission () {
        startButton.isEnabled = true
        
        
        flightController?.simulator?.setFlyZoneLimitationEnabled(false)
        flightController?.setNoviceModeEnabled(false)
        flightController?.setMaxFlightRadiusLimitationEnabled(false)
        flightController?.setSmartReturnToHomeEnabled(true)
        flightController?.confirmSmartReturn(toHomeRequest: true)
        flightController?.setConnectionFailSafeBehavior(DJIConnectionFailSafeBehavior.goHome)
        
        let landAction = DJILandAction()
        landAction.autoConfirmLandingEnabled = true
        let ledController = DJIMutableFlightControllerLEDsSettings()
        ledController.frontLEDsOn = true
        flightController?.setLEDsEnabledSettings(ledController)
        
  
        DJISDKManager.missionControl()?.scheduleElement(DJITakeOffAction())
        DJISDKManager.missionControl()?.scheduleElement(DJIGoToAction(altitude: (Double(flightAltitudeLabel.text ?? "50"))!)!)
        DJISDKManager.missionControl()?.scheduleElement(DJIGoToAction(coordinate: destinationCoordinate!)!)
        DJISDKManager.missionControl()?.scheduleElement(DJIGoToAction(altitude: (Double(destinationAltitudeLabel.text ?? "50"))!)!)
        DJISDKManager.missionControl()?.scheduleElement(DJIShootPhotoAction())
        DJISDKManager.missionControl()?.scheduleElement(DJIGoToAction(altitude: (Double(flightAltitudeLabel.text ?? "50"))!)!)
        DJISDKManager.missionControl()?.scheduleElement(DJIGoToAction(coordinate: (homeCoordinate?.coordinate)!)!)
        DJISDKManager.missionControl()?.scheduleElement(DJILandAction())
        
    }
    
    func overrideSafeRadius() {
        flightController?.setHomeLocationUsingAircraftCurrentLocationWithCompletion({ (Error) in
            if Error != nil {
                self.displayAlert(title: "Override Error", text: "Cannot perform the waypoint execution")
            }
        })
    }
    
    func displayAlert(title: String, text: String) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func returnToHome() {
        flightController?.setHomeLocation(homeCoordinate!)
        flightController?.startGoHome(completion: { (Error) in
            if Error != nil {
                self.displayAlert(title: "RTH Error", text: "Failed to perform RTH")
            }
            else {
                self.displayAlert(title: "RTH Called", text: "Drone will perform RTH")
            }
        })
    }
    
    func getCoordinatesFirebase() {
        if locationFirebase.isEmpty == false {
            let latitude = Double(self.locationFirebase.last!["latitude"] as! String)!
            let longitude = Double(self.locationFirebase.last!["longitude"] as! String)!
            destinationCoordinate = CLLocationCoordinate2DMake(latitude ,longitude)
            
            destAnnotation.coordinate = destinationCoordinate!
            mapView.addAnnotation(self.destAnnotation)
            
            let distance = getDroneCoordinates().distance(from: CLLocation(latitude: destinationCoordinate!.latitude, longitude: destinationCoordinate!.longitude))
            
            displayAlert(title: "Total Distance", text: "The total journey distance is \(distance)")
        }
        else {
            displayAlert(title: "Coordinate Update Error", text: "Destination coordinates not found on the server")
        }
    }
    
    @IBAction func distanceRestrictionOverride(_ sender: UIButton) {
        distanceRestrictionOverride = true
    }
}




