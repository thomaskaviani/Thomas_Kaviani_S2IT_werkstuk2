//
//  VilloStop.swift
//  werkstuk2
//
//  Created by KAVIANI Thomas (s) on 01/06/2018.
//  Copyright © 2018 KAVIANI Thomas (s). All rights reserved.
//

import Foundation
import UIKit
import MapKit


class VilloStop: NSObject, MKAnnotation {
    
    var number:Int64?
    var name:String?
    var address:String?
    var coordinate: CLLocationCoordinate2D
    var bike_stands:Int64?
    var available_bike_stands:Int64?
    var available_bikes:Int64?
    var banking:Bool?
    var bonus:Bool?
    var status:String?
    var contractName:String?
    var lastUpdate:Int64?
    
    
    init(number:Int64, name:String, address:String, coordinate:CLLocationCoordinate2D, bike_stands:Int64, available_bike_stands:Int64, available_bikes:Int64, banking:Bool, bonus:Bool, status:String, contractName:String, lastUpdate:Int64){
        
        self.number = number
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.bike_stands = bike_stands
        self.available_bikes = available_bikes
        self.available_bike_stands = available_bike_stands
        self.banking = banking
        self.bonus = bonus
        self.status = status
        self.contractName = contractName
        self.lastUpdate = lastUpdate
        
    }
    
}
