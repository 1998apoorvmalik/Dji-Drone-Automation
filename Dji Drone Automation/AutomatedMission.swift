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
        DJISDKManager.missionControl()?.startTimeline()
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        DJISDKManager.missionControl()?.pauseTimeline()
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        DJISDKManager.missionControl()?.stopTimeline()
    }
    
    @IBAction func corrButtonPressed(_ sender: UIButton) {
        
        
        if homeCoordinate != nil {
            destinationCoordinate = CLLocationCoordinate2DMake(homeCoordinate!.coordinate.latitude + offset, homeCoordinate!.coordinate.longitude + offset)
            
            destAnnotation.coordinate = destinationCoordinate!
            mapView.addAnnotation(self.destAnnotation)
        }
        
        else {
            displayAlert(title: "Coordinate Update Error", text: "Destination coordinates not found on the server")
        }
        
        initializeMission()
    }
    
    @IBAction func RTHButtonPressed(_ sender: UIButton) {
        returnToHome()

    }
    
    
    func initializeMission () {
        let distance = getDroneCoordinates().distance(from: CLLocation(latitude: destinationCoordinate!.latitude, longitude: destinationCoordinate!.longitude))
        
        displayAlert(title: "Total Distance", text: "The total journey distance is \(distance)")
        
        flightController?.simulator?.setFlyZoneLimitationEnabled(false)
        flightController?.setNoviceModeEnabled(false)
        flightController?.setMaxFlightRadiusLimitationEnabled(false)
        flightController?.setSmartReturnToHomeEnabled(true)
        flightController?.confirmSmartReturn(toHomeRequest: true)
        flightController?.setConnectionFailSafeBehavior(DJIConnectionFailSafeBehavior.goHome)
        
        let landAction = DJILandAction()
        landAction.autoConfirmLandingEnabled = true
        let ledController = DJIMutableFlightControllerLEDsSettings()
        ledController.frontLEDsOn = false
        flightController?.setLEDsEnabledSettings(ledController)
  
        DJISDKManager.missionControl()?.scheduleElement(DJITakeOffAction())
        DJISDKManager.missionControl()?.scheduleElement(DJIGoToAction(altitude: 60)!)
        DJISDKManager.missionControl()?.scheduleElement(DJIGoToAction(coordinate: destinationCoordinate!, altitude: 30)!)
        DJISDKManager.missionControl()?.scheduleElement(DJIShootPhotoAction())
        DJISDKManager.missionControl()?.scheduleElement(landAction)
        
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
    
    @IBAction func textReturnPress(_ sender: Any) {
        offset = NumberFormatter().number(from: textField.text!)!.doubleValue
    }
}



