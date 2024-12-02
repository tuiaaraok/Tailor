//
//  OrdersViewModel.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import Foundation

class OrdersViewModel {
    static let shared = OrdersViewModel()
    private var data: [OrderModel] = []
    @Published var orders: [OrderModel] = []
    var type = 0
    
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchOrders { [weak self] orders, _ in
            guard let self = self else { return }
            self.data = orders
            filter(type: type)
        }
    }
    
    func confirmOrder(id: UUID, completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.confirmOrder(id: id, completion: completion)
    }
    
    func filter(type: Int) {
        self.type = type
        let isCompleted = type == 1
        orders = data.filter({ $0.isCompleted == isCompleted })
    }
    
    func clear() {
        data = []
        orders = []
        type = 0
    }
}
