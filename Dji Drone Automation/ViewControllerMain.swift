//
//  ViewController.swift
//  Dji Drone Automation
//
//  Created by Apoorv Malik on 24/04/19.
//  Copyright © 2019 Apoorv Malik. All rights reserved.
//

import UIKit
import DJISDK


class ViewControllerMain: UIViewController, DJISDKManagerDelegate{
    
    @IBOutlet weak var bindingStateLabel: UILabel!
    @IBOutlet weak var appActivationLabel: UILabel!
    
    var product_connected: Bool = false
    
    @IBAction func startApp(_ sender: UIButton) {
        if product_connected {
            self.performSegue(withIdentifier: "segueToFlightModule", sender: self)
        }
        else {
            print("Error: Product is not connected")
            showAlertViewWithTitle(title: "Error", withMessage: "Product is not connected")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DJISDKManager.registerApp(with: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
