//
//  ViewController.swift
//  ImageClassification
//
//  Created by Sanatan on 6/18/24 based on files created by TensorFlow licensed under the Apache License and later expanded.
//  Copyright © 2024 Sanatan Mishra. All rights reserved.
//

import AVFoundation
import UIKit
import OSLog
import SQLite

class ViewController: UIViewController {

  // MARK: Storyboards Connections
  @IBOutlet weak var previewView: PreviewView!
  @IBOutlet weak var cameraUnavailableLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var settings: UIButton!

  // MARK: Constants
  private let animationDuration = 0.5
  private let collapseTransitionThreshold: CGFloat = -40.0
  private let expandTransitionThreshold: CGFloat = 40.0
  private let delayBetweenInferencesMs = 1000.0
  private let synthesizer = AVSpeechSynthesizer()
  private let voice = AVSpeechSynthesisVoice(language: "en-US")

  // MARK: Instance Variables
  private let inferenceQueue = DispatchQueue(label: "org.tensorflow.lite.inferencequeue")
  private var previousInferenceTimeMs = Date.distantPast.timeIntervalSince1970 * 1000
  private var isInferenceQueueBusy = false
  private var initialBottomSpace: CGFloat = 0.0
  private var threadCount = DefaultConstants.threadCount
  private var maxResults = DefaultConstants.maxResults {
    didSet {
      //guard let inferenceVC = inferenceViewController else { return }
      //bottomViewHeightConstraint.constant = inferenceVC.collapsedHeight + 290
      //view.layoutSubviews()
    }
  }
  private var scoreThreshold = DefaultConstants.scoreThreshold
  private var model: ModelType = .sunnyvale
  private var detectedCategory = ""
    private var pixelBuffer: CVPixelBuffer? = nil
    private var shouldRun = false

  

  // MARK: Controllers that manage functionality
  // Handles all the camera related functionality
  private lazy var cameraCapture = CameraFeedManager(previewView: previewView)

  // Handles all data preprocessing and makes calls to run inference through the
  // `ImageClassificationHelper`.
  private var imageClassificationHelper: ImageClassificationHelper? =
    ImageClassificationHelper(
      modelFileInfo: DefaultConstants.model.modelFileInfo,
      threadCount: DefaultConstants.threadCount,
      resultCount: DefaultConstants.maxResults,
      scoreThreshold: DefaultConstants.scoreThreshold)

  // Handles the presenting of results on the screen
  //private var inferenceViewController: InferenceViewController?

    @IBAction func toSettings(_ sender: Any) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    // MARK: View Handling Methods
    @objc func inferenceModel(sender: UIButton!) {
        if #available(iOS 14.0, *) {
            let logger = Logger()
            logger.info("got clicked")
        } else {
            // Fallback on earlier versions
        }
        // Pass the pixel buffer to TensorFlow Lite to perform inference.
//        if (self.pixelBuffer == nil || self.isInferenceQueueBusy) {
//            return
//        }
        if (UserDefaults().string(forKey: "jurisdiction") == "Sunnyvale") {
            self.model = .sunnyvale
            if #available(iOS 14.0, *) {
                let l = Logger()
                l.log("You are in Sunnyvale")
            } else {
                // Fallback on earlier versions
            }
        } else {
            self.model = .santaclara
        }
        self.shouldRun = true
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()

    guard imageClassificationHelper != nil else {
      fatalError("Model initialization failed.")
    }

    cameraCapture.delegate = self

    //guard let inferenceVC = inferenceViewController else { return }
    //bottomViewHeightConstraint.constant = inferenceVC.collapsedHeight + 290
    view.layoutSubviews()
      shutterButton.addTarget(self, action: #selector(inferenceModel(sender:)), for: UIControl.Event.touchUpInside)
      if (UserDefaults().string(forKey: "jurisdiction") == nil) {
          UserDefaults().set(_: "Sunnyvale", forKey: "jurisdiction")
      }
  }
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {
        
    }
    
        

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    #if !targetEnvironment(simulator)
      cameraCapture.checkCameraConfigurationAndStartSession()
    #endif
  }

  #if !targetEnvironment(simulator)
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      cameraCapture.stopSession()
    }
  #endif

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  func presentUnableToResumeSessionAlert() {
    let alert = UIAlertController(
      title: "Unable to Resume Session",
      message: "There was an error while attempting to resume session.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    self.present(alert, animated: true)
  }

  // MARK: Storyboard Segue Handlers
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
  }
}

// MARK: CameraFeedManagerDelegate Methods
extension ViewController: CameraFeedManagerDelegate {

  func didOutput(pixelBuffer: CVPixelBuffer) {
      DispatchQueue.main.sync {
          cameraCapture.updateOrientation()
      }
    // Make sure the model will not run too often, making the results changing quickly and hard to
    // read.
    let currentTimeMs = Date().timeIntervalSince1970 * 1000
    guard (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else { return }
    previousInferenceTimeMs = currentTimeMs
//      if #available(iOS 14.0, *) {
//          let logger = Logger()
//          logger.info("shouldRun = \(self.shouldRun)")
//          logger.info("isInferenceQueueBusy = \(self.isInferenceQueueBusy)")
//      } else {
//          // Fallback on earlier versions
//      }

    // Drop this frame if the model is still busy classifying a previous frame.
    guard !isInferenceQueueBusy else { return }
      guard shouldRun else { return }

    inferenceQueue.async { [weak self] in
      guard let self = self else { return }

      self.isInferenceQueueBusy = true
        self.shouldRun = false
        self.pixelBuffer = pixelBuffer
        let result = self.imageClassificationHelper?.classify(frame: self.pixelBuffer!)
          let detectedCategoryRaw = displayStringsForResults(row: 0, inferenceResult: result)
          if (result != nil) {
              self.detectedCategory = detectedCategoryRaw.0
              DispatchQueue.main.sync {
                  var spokenText = ""
                  if (self.detectedCategory == "containers") {
                      spokenText = "Container Recycling"
                  } else if (self.detectedCategory == "organics") {
                      spokenText = "Organic Waste"
                  } else if (self.detectedCategory == "paper") {
                      spokenText = "Paper Recycling"
                  } else if (self.detectedCategory == "trash") {
                      spokenText = "Landfill Trash"
                  } else if (self.detectedCategory == "" || self.detectedCategory == "Try Again") {
                      spokenText = "Try Again"
                  }
                  let utterance = AVSpeechUtterance(string: spokenText)
                  utterance.voice = self.voice
                  if (spokenText != "Try Again" && spokenText != "") {
                      self.categoryLabel.text = ""
                      let im = UIImage(named: "\(self.detectedCategory)")
                      self.categoryImage.image = im
                      self.categoryImage.heightAnchor.constraint(equalTo: self.categoryImage.widthAnchor, multiplier: im!.size.height / im!.size.width).isActive = true
                  } else {
                      self.categoryLabel.text = self.detectedCategory
                      self.categoryImage.image = nil
                  }
                  self.synthesizer.speak(utterance)
              
                }
              if #available(iOS 14.0, *) {
                  let logger = Logger()
                  logger.info("category: \(self.detectedCategory)")
                  }
              } else {
                  // Fallback on earlier versions
              }
        self.isInferenceQueueBusy = false
    }
  }

  // MARK: Session Handling Alerts
  func sessionWasInterrupted(canResumeManually resumeManually: Bool) {

    // Updates the UI when session is interupted.
      self.cameraUnavailableLabel.isHidden = false
  }

  func sessionInterruptionEnded() {
    // Updates UI once session interruption has ended.
    if !self.cameraUnavailableLabel.isHidden {
      self.cameraUnavailableLabel.isHidden = true
    }
  }

  func sessionRunTimeErrorOccured() {
    // Handles session run time error by updating the UI and providing a button if session can be
    // manually resumed.
    previewView.shouldUseClipboardImage = true
  }

  func presentCameraPermissionsDeniedAlert() {
    let alertController = UIAlertController(
      title: "Camera Permissions Denied",
      message:
        "Camera permissions have been denied for this app. You can change this by going to Settings",
      preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
      UIApplication.shared.open(
        URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)

    present(alertController, animated: true, completion: nil)

    previewView.shouldUseClipboardImage = true
  }

  func presentVideoConfigurationErrorAlert() {
    let alert = UIAlertController(
      title: "Camera Configuration Failed", message: "There was an error while configuring camera.",
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    self.present(alert, animated: true)
    previewView.shouldUseClipboardImage = true
  }
}



// Define default constants
enum DefaultConstants {
  static let threadCount = 4
  static let maxResults = 3
  static let scoreThreshold: Float = 0.2
  static let model: ModelType = .sunnyvale
}

/// TFLite model types
enum ModelType: CaseIterable {
  case sunnyvale
    case santaclara

  var modelFileInfo: FileInfo {
    switch self {
    case .sunnyvale:
      return FileInfo("sunnyvale-final", "tflite")
        case .santaclara:
            return FileInfo("santaclara-final", "tflite")
    }
  }

  var title: String {
    switch self {
    case .sunnyvale:
      return "MobileNet-v2"
        case .santaclara:
            return "MobileNet-v2"
    }
  }
}

func displayStringsForResults(row: Int, inferenceResult: ImageClassificationResult?) -> (fieldName: String, info: String) {
  var fieldName: String = ""
  var info: String = ""
    if #available(iOS 14.0, *) {
        let l = Logger()
        l.log("\((inferenceResult!).classifications.categories.count)")
    } else {
        // Fallback on earlier versions
    }

  guard let tempResult = inferenceResult, tempResult.classifications.categories.count > 0 else {

    if row == 1 {
      fieldName = "Try Again"
      info = ""
    } else {
      fieldName = ""
      info = ""
    }
    return (fieldName, info)
  }
    if #available(iOS 14.0, *) {
        let l = Logger()
        l.log("\(tempResult.classifications.categories[0].label!)")
    } else {
        // Fallback on earlier versions
    }

  if row < tempResult.classifications.categories.count {
    let category = tempResult.classifications.categories[row]
    fieldName = category.label ?? ""
    info = String(format: "%.2f", category.score * 100.0) + "%"
  } else {
    fieldName = ""
    info = ""
  }

    return (fieldName: fieldName, info: info)
}

