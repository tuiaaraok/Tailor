//
//  SettingsViewController.swift
//  Tailor
//
//  Created by Karen Khachatryan on 03.12.24.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var settingsButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButtons.forEach({ $0.titleLabel?.font = .bold(size: 30); $0.addShadow() })
    }
    
    @IBAction func clickedContactUs(_ sender: UIButton) {
    }
    @IBAction func clickedPrivacyPolicy(_ sender: UIButton) {
    }
    @IBAction func clickedRateUs(_ sender: UIButton) {
    }
}
