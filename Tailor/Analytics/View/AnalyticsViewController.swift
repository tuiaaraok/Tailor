//
//  AnalyticsViewController.swift
//  Tailor
//
//  Created by Karen Khachatryan on 03.12.24.
//

import UIKit
import Combine

class AnalyticsViewController: UIViewController {
    
    @IBOutlet var periodButtons: [BaseButton]!
    @IBOutlet weak var productsLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var incomeLabelWidthConst: NSLayoutConstraint!
    private let viewModel = AnalyticsViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNaviagtionBackButton()
        setNavigationTitle(title: "Analytics")
        progressView.layer.cornerRadius = 2
        progressView.layer.masksToBounds = true
        incomeLabel.font = .regular(size: 15)
        expenseLabel.font = .regular(size: 15)
        periodButtons.forEach({ $0.addShadow()} )
    }
    
    func subscribe() {
        viewModel.$orders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] orders in
                guard let self = self else { return }
                self.periodButtons.forEach({ $0.isSelected = false })
                self.periodButtons[self.viewModel.period].isSelected = true
                let productsCount = "\(orders.count)"
                let productsSold = "products sold"

                let productsCountAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.aurore(size: 50) ?? .systemFont(ofSize: 20)]
                let productsSoldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.regular(size: 20) ?? .systemFont(ofSize: 16)]
                let attributedProductsCount = NSAttributedString(string: productsCount, attributes: productsCountAttributes)
                let attributedProductsSold = NSAttributedString(string: productsSold, attributes: productsSoldAttributes)
                let combinedAttributedString = NSMutableAttributedString()
                combinedAttributedString.append(attributedProductsCount)
                combinedAttributedString.append(attributedProductsSold)
                self.productsLabel.attributedText = combinedAttributedString
                self.incomeLabel.text = "  Income \(self.viewModel.income().formattedToString())$"
                self.expenseLabel.text = "  Expense \(self.viewModel.expense().formattedToString())$"
                if self.viewModel.income() != 0 {
                    let result = viewModel.expense() / viewModel.income()
                    if result > 0 {
                        let progress = Double(progressView.bounds.width) / (result + 1)
                        self.incomeLabelWidthConst.constant = progress
                    } else {
                        self.incomeLabelWidthConst.constant = progressView.bounds.width
                    }
                } else if viewModel.expense() == 0 {
                    self.incomeLabelWidthConst.constant = progressView.bounds.width / 2
                } else {
                    self.incomeLabelWidthConst.constant = 0
                }
            }
            .store(in: &cancellables)
    }

    @IBAction func choosePeriod(_ sender: BaseButton) {
        viewModel.filterByPeriod(period: sender.tag)
    }
}
