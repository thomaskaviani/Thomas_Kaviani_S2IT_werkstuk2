//
//  ViewController.swift
//  werkstuk2
//
//  Created by KAVIANI Thomas (s) on 01/06/2018.
//  Copyright © 2018 KAVIANI Thomas (s). All rights reserved.
//

import UIKit
import MapKit
import SystemConfiguration
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {

    let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
    
    var villoStops = [Stop]()
    var manager = CLLocationManager()
    
    @IBOutlet weak var updatelabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBAction func refresh(_ sender: Any) {
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radius: CLLocationDistance = 5000
        let center = CLLocationCoordinate2D(latitude: 50.847413, longitude: 4.351266)
        let region = MKCoordinateRegionMakeWithDistance(center, radius, radius)
        self.map.setRegion(region, animated: true)
        
        refresh()
        
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
    }

    func refresh(){
        print("deletedata")
        deleteData()
        villoStops = []
        print("deletepins")
        deletePins()
        getData()
        let time = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .medium)
        updatelabel.text = time
    }
    
    func getData(){
        
        print("getData")
        let url = URLRequest(url: self.url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stop")
        request.returnsObjectsAsFaults = false
        
        do {
            let stops = try context.fetch(request) as! [Stop]
            if (stops.count > 0) {
                for villoStop in stops {
                    self.villoStops.append(villoStop)
                }
            } else {
                DispatchQueue.main.async {
                    let task = session.dataTask(with: url){
                        (data, response, error) in
                        
                        guard error == nil else {
                            print("Error: Json error")
                            print(error!)
                            return
                        }
                        
                        guard let responseData = data else {
                            print("Error: Responsedata error")
                            return
                        }
                        print("jsonparske")
                        let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! NSArray
                        print("jsonparske")
                        for object in json {
                            let stop = NSEntityDescription.insertNewObject(forEntityName: "Stop", into: context) as! Stop
                            let obj = (object as! NSDictionary)
                            let position = ((object as! NSDictionary).value(forKey: "position")) as! NSDictionary
                            
                            let villoStop = VilloStop(number: (obj.value(forKey: "number") as? Int64)!, name: (obj.value(forKey: "name") as? String)!, address: obj.value(forKey: "address") as! String, coordinate: CLLocationCoordinate2D(latitude: position.value(forKey: "lat") as! CLLocationDegrees, longitude: position.value(forKey: "lng") as! CLLocationDegrees), bike_stands: (obj.value(forKey: "bike_stands") as? Int64)!, available_bike_stands:(obj.value(forKey: "available_bike_stands") as? Int64)!, available_bikes:(obj.value(forKey: "available_bikes") as? Int64)!, banking:(obj.value(forKey: "banking") as! Bool), bonus: (obj.value(forKey: "banking") as! Bool), status: obj.value(forKey: "status") as! String, contractName:obj.value(forKey: "contract_name") as! String, lastUpdate: (obj.value(forKey: "last_update") as? Int64)!)
                            
                            stop.number = villoStop.number!
                            stop.name = villoStop.name
                            stop.address = villoStop.address
                            stop.latitude = Double(villoStop.coordinate.latitude)
                            stop.longitude = Double(villoStop.coordinate.longitude)
                            stop.bike_stands = villoStop.bike_stands!
                            stop.available_bike_stands = villoStop.available_bike_stands!
                            stop.available_bikes = villoStop.available_bikes!
                            stop.banking = villoStop.banking!
                            stop.bonus = villoStop.bonus!
                            stop.contractName = villoStop.contractName
                            stop.lastUpdate = villoStop.lastUpdate!
                            stop.status = villoStop.status!
                            
                            print("append stop")
                            self.villoStops.append(stop)
                        }
                        
                        do {
                            print("try context save")
                            try context.save()
                            print("showPinsMap")
                            self.showPinsMap()
                        } catch {
                            fatalError("Error context error")
                        }
                        
                    }
                    task.resume()
                }
            }
            
        } catch {
            fatalError("Errormessage - 1")
        }
        
    }
    
    
    func showPinsMap(){
        print("show pins")
        for stop in villoStops {
            print(stop.latitude)
            print(stop.longitude)
            DispatchQueue.main.async {
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
                
                let pin = Pin(coordinate: coordinate, title: stop.name!)
                
                self.map.addAnnotation(pin)
            }
        }
    }
    
    func deletePins(){
        
    }
    
    func deleteData(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    

}

