//
//  PortfolioModel.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import Foundation

struct PortfolioModel {
    var id: UUID
    var fur: String?
    var info: String?
    var photos: [Data] = []
}
