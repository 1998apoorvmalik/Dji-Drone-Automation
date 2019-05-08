//
//  ViewController.swift
//  Dji Drone Automation
//
//  Created by Apoorv Malik on 24/04/19.
//  Copyright © 2019 Apoorv Malik. All rights reserved.
//

import UIKit
import DJISDK
import Firebase


class ViewControllerMain: UIViewController, DJISDKManagerDelegate{
    
    @IBOutlet weak var bindingStateLabel: UILabel!
    @IBOutlet weak var appActivationLabel: UILabel!
    
    var product_connected: Bool = false
    
    @IBAction func startApp(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToFlightModule", sender: self)
        if product_connected {
            self.performSegue(withIdentifier: "segueToFlightModule", sender: self)
        }
        else {
            print("Error: Product is not connected")
            showAlertViewWithTitle(title: "Error", withMessage: "Product is not connected")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().signIn(withEmail: "apoorv258@gmail.com", password: "2e7f76b2") { [weak self] user, error in
            guard self != nil else { return }
            if error == nil {
                self!.showAlertViewWithTitle(title:"Firebase Sign in", withMessage: "Sucessfully signed in")
            }
            else {
                self!.showAlertViewWithTitle(title:"Firebase Sign in", withMessage: "Error while signing in")
                Auth.auth().createUser(withEmail: "apoorv258@gmail.com", password: "2e7f76b2") { authResult, error in
                    if error == nil {
                        self!.showAlertViewWithTitle(title:"Firebase Registration", withMessage: "New user created, please restart the app")
                    }
                    else {
                        self!.showAlertViewWithTitle(title:"Firebase Registration", withMessage: "Error while creating new user")
                    }
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        super.viewDidDisappear(animated)
        DJISDKManager.registerApp(with: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlertViewWithTitle(title: String, withMessage message: String) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title:"OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // DJISDKManagerDelegate Methods
    func productConnected(_ product: DJIBaseProduct?) {
        product_connected = true
        print("Product Connected")
        bindingStateLabel.text = "Product Connected"
        DJISDKManager.startListeningOnProductConnectionUpdates(withListener: self) { _ in
            if self.product_connected {
                print("Connection Re-established")
            }
            else {
                print("Connection Lost")
            }
        }
    }
    
    func productDisconnected() {
        
        product_connected = false
        print("Product Disconnected")
        bindingStateLabel.text = "Product Disconnected"
    }
    
    func appRegisteredWithError(_ error: Error?) {
        var message = "Register App Successed!"
        if (error != nil) {
            message = "Register app failed! Please enter your app key and check the network."
            appActivationLabel.text = "Error"
        }
        else {
            appActivationLabel.text = "Activated"
            DJISDKManager.startConnectionToProduct()
        }
        showAlertViewWithTitle(title:"Register App", withMessage: message)
    }
}
