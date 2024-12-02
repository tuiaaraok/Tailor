//
//  OrderFormViewController.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import UIKit
import DropDown
import Combine

class OrderFormViewController: UIViewController {

    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var clientTextField: BaseTextField!
    @IBOutlet weak var phoneNumberTextField: BaseTextField!
    @IBOutlet weak var costMaterialTextField: PricesTextField!
    @IBOutlet weak var productCostTextField: PricesTextField!
    @IBOutlet weak var descriptionTextView: PaddingTextView!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var dropDownImageView: UIImageView!
    private let priorityDropDown = DropDown()
    private let viewModel = OrderFormViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDropDown()
        subscribe()
    }
    
    override func viewDidLayoutSubviews() {
        priorityDropDown.width = priorityButton.bounds.width
        priorityDropDown.bottomOffset = CGPoint(x: priorityButton.frame.minX, y: priorityButton.frame.maxY + 2)
    }
    
    func setupUI() {
        setNavigationTitle(title: "Orders")
        navigationItem.hidesBackButton = true
        priorityButton.layer.borderColor = UIColor.black.cgColor
        priorityButton.layer.borderWidth = 1
        priorityButton.layer.cornerRadius = 8
        priorityButton.titleLabel?.font = .regular(size: 18)
        clientTextField.delegate = self
        phoneNumberTextField.delegate = self
        costMaterialTextField.baseDelegate = self
        productCostTextField.baseDelegate = self
        descriptionTextView.delegate = self
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.cornerRadius = 8
    }
    
    func setupDropDown() {
        let data: [String] = Priority.allCases.map { $0.rawValue }
        priorityDropDown.backgroundColor = .white
        priorityDropDown.layer.cornerRadius = 16
        priorityDropDown.dataSource = data
        priorityDropDown.anchorView = view
        priorityDropDown.direction = .bottom
        DropDown.appearance().textColor = .black
        DropDown.appearance().textFont = .regular(size: 18) ?? .boldSystemFont(ofSize: 18)
        priorityDropDown.addShadow()
        
        priorityDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.viewModel.order.priority = index
            self.dropDownImageView.isHighlighted = false
        }
        
        priorityDropDown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.dropDownImageView.isHighlighted = false
        }
    }
    
    func subscribe() {
        viewModel.$order
            .receive(on: DispatchQueue.main)
            .sink { [weak self] order in
                guard let self = self else { return }
                self.clientTextField.text = order.client
                self.phoneNumberTextField.text = order.phoneNumber
                if let materialCost = order.costOfMaterials {
                    self.costMaterialTextField.text = self.costMaterialTextField.formatPrice(input: materialCost.formattedToString())
                } else {
                    self.costMaterialTextField.text = nil
                }
                if let productCost = order.productCost {
                    self.productCostTextField.text = self.productCostTextField.formatPrice(input: productCost.formattedToString())
                } else {
                    self.productCostTextField.text = nil
                }
                if let priority = order.priority {
                    self.priorityButton.setTitle(Priority.allCases[priority].rawValue, for: .normal)
                } else {
                    priorityButton.setTitle(nil, for: .normal)
                }
                self.descriptionTextView.text = order.info
                self.saveButton.isEnabled = (order.client.checkValidation() && order.phoneNumber.checkValidation() && order.costOfMaterials != nil && order.productCost != nil && order.info.checkValidation() && order.priority != nil)
            }
            .store(in: &cancellables)
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func choosePriority(_ sender: UIButton) {
        priorityDropDown.show()
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.completion?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        viewModel.clear()
    }
}

extension OrderFormViewController: UITextFieldDelegate, PriceTextFielddDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case clientTextField:
            viewModel.order.client = textField.text
        case phoneNumberTextField:
            viewModel.order.phoneNumber = textField.text
        case costMaterialTextField:
            if let textWithoutSpaces = costMaterialTextField.text?.components(separatedBy: .whitespacesAndNewlines).joined() {
                viewModel.order.costOfMaterials = Double(textWithoutSpaces)
            }
        case productCostTextField:
            if let textWithoutSpaces = productCostTextField.text?.components(separatedBy: .whitespacesAndNewlines).joined() {
                viewModel.order.productCost = Double(textWithoutSpaces)
            }
        default:
            break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

extension OrderFormViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        viewModel.order.info = textView.text
    }
}


