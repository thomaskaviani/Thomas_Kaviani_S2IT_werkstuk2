//
//  ViewControllerDetail.swift
//  werkstuk2
//
//  Created by KAVIANI Thomas (s) on 03/06/2018.
//  Copyright © 2018 KAVIANI Thomas (s). All rights reserved.
//

import UIKit

class ViewControllerDetail: UIViewController {
    
    var stop:Stop = Stop()

    @IBOutlet weak var stopNaam: UILabel!
    @IBOutlet weak var totaalPlaatsenLabel: UILabel!
    
    @IBOutlet weak var beschikbareFietsenLabel: UILabel!
    
    @IBOutlet weak var beschikbarePlaatsenLabel: UILabel!
    
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var bonusLabel: UILabel!
    
    @IBOutlet weak var adresLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stopNaam.text = self.stop.name
        self.adresLabel.text = self.stop.address
        if(self.stop.banking) {
            self.bankLabel.text = "YES"
            self.bankLabel.textColor = UIColor.green
        } else {
            self.bankLabel.text = "NO"
            self.bankLabel.textColor = UIColor.red
        }
        if(self.stop.bonus) {
            self.bonusLabel.text = "YES"
            self.bonusLabel.textColor = UIColor.green
        } else {
            self.bonusLabel.text = "NO"
            self.bonusLabel.textColor = UIColor.red
        }
        self.totaalPlaatsenLabel.text = String(self.stop.bike_stands)
        if(self.stop.status == "OPEN") {
            self.statusLabel.text = self.stop.status
            self.statusLabel.textColor = UIColor.green
        } else {
            self.statusLabel.text = self.stop.status
            self.statusLabel.textColor = UIColor.red
        }
        self.beschikbarePlaatsenLabel.text = String(self.stop.available_stands)
        self.beschikbareFietsenLabel.text = String(self.stop.available_bikes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    

}
