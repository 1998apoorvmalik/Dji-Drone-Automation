//
//  Annotation.swift
//  
//
//  Created by Apoorv Malik on 24/04/19.
//

import Foundation
import DJISDK

class CustomPointAnnotation: MKPointAnnotation {
    var identifier = "N/A"
    
    convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinates
    }
}

class DJIImageAnnotation: MKPointAnnotation {
    
    var identifier = "N/A"
    var imageDJI: UIImage!
    
    fileprivate var _heading: Double = 0.0
    public var heading: Double {
        get {
            return _heading
        }
        set {
            _heading = newValue
        }
    }
    
    convenience init(identifier: String, customImage: UIImage) {
        self.init()
        self.identifier = identifier
        self.imageDJI = customImage
    }
    
    convenience init(coordinates: CLLocationCoordinate2D, heading: Double) {
        self.init()
        self.coordinate = coordinates
        _heading = heading
    }
}
