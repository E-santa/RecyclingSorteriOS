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

    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func setJurisdiction(_ sender: UIButton) {
        UserDefaults().set(_: "Sunnyvale", forKey: "jurisdiction")
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
