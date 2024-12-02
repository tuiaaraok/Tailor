//
//  OrderTableViewCell.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import UIKit

protocol OrderTableViewCellDelegate: AnyObject {
    func edit(id: UUID, cell: UITableViewCell)
    func confirm(id: UUID, cell: UITableViewCell)
}

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet var infoLabels: [UILabel]!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var productCostLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    weak var delegate: OrderTableViewCellDelegate?
    private var id: UUID?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoLabels.forEach({ $0.font = .regular(size: 18) })
        bgView.layer.cornerRadius = 13
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(order: OrderModel) {
        self.backgroundColor = .clear
        if let priority = order.priority {
            bgView.backgroundColor = UIColor(named: "priority\(Priority.allCases[priority].rawValue)")
        }
        id = order.id
        clientLabel.text = "Client: \(order.client ?? "")"
        phoneLabel.text = "Phone number \(order.phoneNumber ?? "")"
        productCostLabel.text = "Product cost: \(order.productCost?.formattedToString() ?? "")$"
        descriptionLabel.text = "Description: \(order.info ?? "")"
        checkboxButton.isHidden = order.isCompleted
    }
    
    @IBAction func clickedEdit(_ sender: UIButton) {
        if let id = id {
            delegate?.edit(id: id, cell: self)
        }
    }
    
    @IBAction func clickedCheckbox(_ sender: UIButton) {
        if let id = id {
            delegate?.confirm(id: id, cell: self)
        }
    }
}
