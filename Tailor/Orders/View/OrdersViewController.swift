//
//  OrdersViewController.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import UIKit
import Combine

class OrdersViewController: UIViewController {

    @IBOutlet var filterButtons: [BaseButton]!
    @IBOutlet weak var ordersTableView: UITableView!
    private let viewModel = OrdersViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    private let addButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNaviagtionBackButton()
        setNavigationTitle(title: "Orders")
        addButton.addTarget(self, action: #selector(addOrder), for: .touchUpInside)
        addButton.setTitle("+Add", for: .normal)
        addButton.setTitleColor(.button, for: .normal)
        addButton.titleLabel?.font = .regular(size: 22)
        setNaviagtionRightButton(button: addButton)
        filterButtons.forEach({ $0.addShadow()} )
        ordersTableView.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderTableViewCell")
        ordersTableView.delegate = self
        ordersTableView.dataSource = self
    }
    
    func subscribe() {
        viewModel.$orders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.filterButtons.forEach({ $0.isSelected = false })
                self.filterButtons[self.viewModel.type].isSelected = true
                self.ordersTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func openOrderForm() {
        let orderFormVC = OrderFormViewController(nibName: "OrderFormViewController", bundle: nil)
        orderFormVC.completion = { [weak self] in
            guard let self = self else { return }
            viewModel.fetchData()
        }
        self.navigationController?.pushViewController(orderFormVC, animated: true)
    }
    
    @objc func addOrder() {
        openOrderForm()
    }
    
    @IBAction func chooseFilter(_ sender: BaseButton) {
        viewModel.filter(type: sender.tag)
    }
}

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.orders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
        cell.configure(order: viewModel.orders[indexPath.section])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
}

extension OrdersViewController: OrderTableViewCellDelegate {
    func edit(id: UUID, cell: UITableViewCell) {
        if let indexPath = ordersTableView.indexPath(for: cell) {
            OrderFormViewModel.shared.order = viewModel.orders[indexPath.section]
            openOrderForm()
        }
    }
    
    func confirm(id: UUID, cell: UITableViewCell) {
        if let indexPath = ordersTableView.indexPath(for: cell) {
            viewModel.confirmOrder(id: viewModel.orders[indexPath.section].id) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.showErrorAlert(message: error.localizedDescription)
                } else {
                    viewModel.fetchData()
                }
            }
        }
    }
}
