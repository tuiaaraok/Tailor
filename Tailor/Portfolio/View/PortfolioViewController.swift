//
//  PortfolioViewController.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import UIKit
import Combine

class PortfolioViewController: UIViewController {

    @IBOutlet weak var portfolioCollectionView: UICollectionView!
    private let viewModel = PortfolioViewModel.shared
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
        setNavigationTitle(title: "Portfolio")
        addButton.addTarget(self, action: #selector(addPortfolio), for: .touchUpInside)
        addButton.setTitle("+Add", for: .normal)
        addButton.setTitleColor(.button, for: .normal)
        addButton.titleLabel?.font = .regular(size: 22)
        setNaviagtionRightButton(button: addButton)
        
        let layout = UICollectionViewFlowLayout()
        let totalSpacing: CGFloat = 88 + 14
        let itemWidth = (view.frame.size.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 200)
        layout.minimumInteritemSpacing = 14
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets(top: 8, left: 40, bottom: 0, right: 40)
        portfolioCollectionView.collectionViewLayout = layout
        portfolioCollectionView.allowsMultipleSelection = false
        portfolioCollectionView.register(UINib(nibName: "PortfolioCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "PortfolioCollectionViewCell")
        portfolioCollectionView.delegate = self
        portfolioCollectionView.dataSource = self
    }
    
    func subscribe() {
        viewModel.$portfolio
            .receive(on: DispatchQueue.main)
            .sink { [weak self] portfolio in
                guard let self = self else { return }
                self.portfolioCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func openPortfoiloFormVC() {
        let portfoiloFormVC = PortfolioFormViewController(nibName: "PortfolioFormViewController", bundle: nil)
        portfoiloFormVC.completion = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchData()
        }
        self.navigationController?.pushViewController(portfoiloFormVC, animated: true)
    }
    
    @objc func addPortfolio() {
        openPortfoiloFormVC()
    }
    
}

extension PortfolioViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.portfolio.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortfolioCollectionViewCell", for: indexPath) as! PortfolioCollectionViewCell
        cell.configure(portfolio: viewModel.portfolio[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PortfolioFormViewModel.shared.portfolio = viewModel.portfolio[indexPath.item]
        openPortfoiloFormVC()
    }
}
