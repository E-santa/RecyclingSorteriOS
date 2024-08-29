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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jurisdictionPicker.dataSource = self
        jurisdictionPicker.delegate = self
    }
    
    
    @IBAction func setJurisdiction(_ sender: UIButton) {
        let pickedValue = jurisdictionPicker.selectedRow(inComponent: 0)
        UserDefaults().set(_: pickerView(jurisdictionPicker, titleForRow: pickedValue, forComponent: 0), forKey: "jurisdiction")
    }
    
    @IBAction func backToHome(unwindSegue: UIStoryboardSegue) {
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
        switch component {
            case 0:
                return 0
            case 1:
                return 1
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            switch component {
            case 0:
                return "Sunnyvale"
            case 1:
                return "Santa Clara"
            default:
                return "Sunnyvale"
            }
        }
}
