//
//  BaseButton.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import UIKit

class BaseButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? self.backgroundColor?.withAlphaComponent(1) : self.backgroundColor?.withAlphaComponent(0.5)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .button : .baseGray
        }
    }
    
    func commonInit() {
        self.titleLabel?.font = .regular(size: 22)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .button
        self.layer.cornerRadius = 8
        self.addShadow()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
