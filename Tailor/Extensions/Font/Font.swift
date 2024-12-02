//
//  Font.swift
//  Graffity
//
//  Created by Karen Khachatryan on 25.11.24.
//

import UIKit

extension UIFont {
    static func regular(size: CFloat) -> UIFont? {
        return UIFont(name: "Jaldi-Regular", size: CGFloat(size))
    }
    
    static func bold(size: CFloat) -> UIFont? {
        return UIFont(name: "Jaldi-Bold", size: CGFloat(size))
    }
}
