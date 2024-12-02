//
//  OrderModel.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import Foundation

struct OrderModel {
    var id: UUID
    var date: Date = Date().stripTime()
    var client: String?
    var phoneNumber: String?
    var costOfMaterials: Double?
    var productCost: Double?
    var priority: Int?
    var info: String?
    var completionDate: Date?
    var isCompleted = false
}

enum Priority: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}
