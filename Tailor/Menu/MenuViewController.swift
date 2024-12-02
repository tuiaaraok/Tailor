//
//  MenuViewController.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet var menuButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButtons.forEach({ $0.titleLabel?.font = .bold(size: 30); $0.addShadow() })
    }

    @IBAction func clickedPortfolio(_ sender: Any) {
    }
    @IBAction func clickedOrders(_ sender: UIButton) {
    }
    @IBAction func clickedAnalytics(_ sender: UIButton) {
    }
    @IBAction func clickedSettings(_ sender: UIButton) {
    }
}
