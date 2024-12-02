//
//  PortfolioViewModel.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import Foundation

class PortfolioViewModel {
    static let shared = PortfolioViewModel()
    @Published var portfolio: [PortfolioModel] = []
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchPortfolio { [weak self] portfolio, _ in
            guard let self = self else { return }
            self.portfolio = portfolio
        }
    }
    
    func clear() {
        portfolio = []
    }
}
