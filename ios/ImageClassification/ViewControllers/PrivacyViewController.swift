//
//  PrivacyViewController.swift
//  ImageClassification
//
//  Created by Sanatan on 9/3/24.
//  Copyright © 2024 Sanatan Mishra. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    @IBOutlet weak var privacy: UITextView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var backButton: UIButton!
    let privacyText =
    """
    <div style="font-family: 'Avenir Next', BlinkMacSystemFont, sans-serif;">
        <h1> PRIVACY POLICY </h1>
    <p> By Sanatan Mishra </p>
        <ol>
        <li><h3>Advertisements</h3>
        <p>No advertisements are displayed to any users.</p></li>

        <li><h3>Data Collection</h3>
        <p>We collect zero user data except the user's recycling jurisdiction, which is stored locally on the device and not shared with anyone. All calculations and analyses are done locally on the device running the application. No user data is even relayed back to our backend because there is no backend.</p>

        <p>User waste is accessed through the camera in real time only while the app is being used, and this data is not stored anywhere.</p></li>

        <li><h3>Social</h3>
        <p>There is no social aspect to this application and no user data is shared with any other users.</p></li>

        <li><h3>APIs and SDKs</h3>
        <p>No APIs or SDKs that collect any user data or otherwise have any type of age screen are used in this application.</p></li>

        <li><h3>Content</h3>
        <p>All content is appropriate for ages 12 and up.</p></li>
        </ol>

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
