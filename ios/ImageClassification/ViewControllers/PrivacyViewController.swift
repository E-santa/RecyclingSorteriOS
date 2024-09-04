//
//  PrivacyViewController.swift
//  ImageClassification
//
//  Created by Sanatan on 9/3/24.
//  Copyright © 2024 Y Media Labs. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    @IBOutlet weak var privacy: UITextView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var backButton: UIButton!
    let privacyText =
    """
    <div style="font-family: -apple-system, BlinkMacSystemFont, sans-serif;">
    <h2>Advertisements</h2>
    <p>No advertisements are displayed to any users.</p>

    <h2>Data Collection</h2>
    <p>We collect zero user data whatsoever. All calculations and analyses are done locally on the device running the application. No user data is even relayed back to our backend because there is no backend.</p>

    <p>User waste is accessed through the camera in real time only while the app is being used, and this data is not stored anywhere.</p>

    <h2>Social</h2>
    <p>There is no social aspect to this application and no user data is shared with any other users.</p>

    <h2>APIs and SDKs</h2>
    <p>No APIs or SDKs that collect any user data or otherwise have any type of age screen are used in this application.</p>

    <h2>Content</h2>
    <p>All content is appropriate for ages 12 and up.</p>

    <h2>Inquiries</h2>
    <p>Contact Sanatan Mishra at <a href="mailto:santarad280@gmail.com">santarad280@gmail.com</a> to submit inquiries.</p>
    </div>
    """

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.privacy.attributedText = privacyText.htmlAttributedString()
        self.privacy.textColor = UIColor(named: "darkOrLight")
        self.privacy.backgroundColor = UIColor(named: "background")
        self.header.font = UIFont.preferredFont(forTextStyle: .title2).bold()
        self.header.adjustsFontForContentSizeCategory = true
    }
    
    @IBAction func backToEncouragement(_ sender: Any) {
        //performSegue(withIdentifier: "unwindFromPrivacy", sender: self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
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

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else { return nil }
        return html
    }
}

extension NSMutableAttributedString {

    public func setAsLink(textToFind:String, linkURL:String) -> Bool {

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
