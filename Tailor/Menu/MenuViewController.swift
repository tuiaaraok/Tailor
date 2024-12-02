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
        self.pushViewController(PortfolioViewController.self)
    }
    
    @IBAction func clickedOrders(_ sender: UIButton) {
        self.pushViewController(OrdersViewController.self)
    }
    
    @IBAction func clickedAnalytics(_ sender: UIButton) {
        self.pushViewController(AnalyticsViewController.self)
    }
    
    @IBAction func clickedSettings(_ sender: UIButton) {
    }
}
