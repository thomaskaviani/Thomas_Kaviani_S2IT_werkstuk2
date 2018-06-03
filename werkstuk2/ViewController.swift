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
    
    @IBOutlet weak var adresLabel: UILabel!
    @IBOutlet weak var fietsenVrijLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        map.showsUserLocation = true
        
    }

    func refresh(){
        deleteData()
        villoStops = []
        deletePins()
        getData()
        self.adresLabel.text = "Adres: "
        self.fietsenVrijLabel.text = "Fietsen vrij: "
        self.statusLabel.text = "Status: "
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
                print("coredata is full")
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
                            
                            self.villoStops.append(stop)
                        }
                        
                        do {
                            print("try context save")
                            try context.save()
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
        for stop in villoStops {
            DispatchQueue.main.async {
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
                
                let pin = Pin(coordinate: coordinate, title: stop.name!)
                
                self.map.addAnnotation(pin)
            }
        }
    }
    
    
    func deletePins(){
        let allPins = self.map.annotations
        self.map.removeAnnotations(allPins)
        
    }
    
    func deleteData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stop")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            for obj in results {
                let objData:NSManagedObject = obj as! NSManagedObject
                context.delete(objData)
            }
        } catch let error as NSError {
            print("Detele all data error: \(error) \(error.userInfo)")
        }
        
    }
    
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pin
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        
        map.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stop = view.annotation
        
        for currentStop in villoStops{
            if(currentStop.name == (stop?.title)!){
                self.adresLabel.text = "Adres: " + currentStop.address!
                self.fietsenVrijLabel.text = "Fietsen vrij: " + String(currentStop.available_bikes)
                self.statusLabel.text = "Status: " + currentStop.status!
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    

}

