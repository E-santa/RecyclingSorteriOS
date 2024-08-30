//
//  SettingsViewController.swift
//  ImageClassification
//
//  Created by Sanatan on 8/27/24.
//  Copyright © 2024 Y Media Labs. All rights reserved.
//

import OSLog
import UIKit
import AVFAudio
import AVFoundation

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var jurisdictionPicker: UIPickerView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    let jurisdictions = [
        "Sunnyvale",
        "Santa Clara"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jurisdictionPicker.dataSource = self
        jurisdictionPicker.delegate = self
        jurisdictionPicker.reloadAllComponents()
    }
    
    
    @IBAction func setJurisdiction(_ sender: UIButton) {
        let pickedValue = jurisdictionPicker.selectedRow(inComponent: 0)
        UserDefaults().set(_: jurisdictions[pickedValue], forKey: "jurisdiction")
        if #available(iOS 14.0, *) {
            let l = Logger()
            l.log("Set Jurisdiction to \(self.jurisdictions[pickedValue])")
        } else {
            // Fallback on earlier versions
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsViewController: UIPickerViewDelegate {
    
}

extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return jurisdictions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return jurisdictions[row]
        }
}
