//
//  AnalyticsViewModel.swift
//  Tailor
//
//  Created by Karen Khachatryan on 03.12.24.
//

import Foundation

class AnalyticsViewModel {
    static let shared = AnalyticsViewModel()
    private var data: [OrderModel] = []
    @Published var orders: [OrderModel] = []
    var period = 0
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchCompletedOrders { [weak self] orders, _ in
            guard let self = self else { return }
            self.data = orders
            filterByPeriod(period: self.period)
        }
    }
    
    func filterByPeriod(period: Int) {
        self.period = period
        if period == 0 {
            filterOrdersForMonth()
        } else {
            filterOrdersForYear()
        }
    }
    
    func filterOrdersForMonth() {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        orders = data.filter { order in
            guard let completionDate = order.completionDate else { return false }
            let components = calendar.dateComponents([.year, .month], from: completionDate)
            return components.year == currentYear && components.month == currentMonth
        }
    }
    
    func filterOrdersForYear() {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        
        orders = data.filter { order in
            guard let completionDate = order.completionDate else { return false }
            let components = calendar.dateComponents([.year], from: completionDate)
            return components.year == currentYear
        }
    }
    
    func income() -> Double {
        return orders.reduce(0, { $0 + ($1.productCost ?? 0) })
    }
    
    func expense() -> Double {
        return orders.reduce(0, { $0 + ($1.costOfMaterials ?? 0)})
    }
}
