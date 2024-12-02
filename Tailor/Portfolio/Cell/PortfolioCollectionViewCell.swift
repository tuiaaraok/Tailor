//
//  PortfolioCollectionViewCell.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import UIKit
import FSPagerView

class PortfolioCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl!
    @IBOutlet weak var furLabel: UILabel!
    private var portfolio: PortfolioModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .baseGray
        self.layer.cornerRadius = 6
        pagerView.layer.cornerRadius = 6
        pagerView.layer.masksToBounds = true
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.contentMode = .scaleAspectFit
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.itemSize = pagerView.bounds.size
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pageControl.contentHorizontalAlignment = .center
        pageControl.setFillColor(.white, for: .selected)
        pageControl.setFillColor(.black, for: .normal)
    }

    func configure(portfolio: PortfolioModel) {
        self.furLabel.text = portfolio.fur
        self.portfolio = portfolio
        self.pageControl.numberOfPages = portfolio.photos.count
        self.pagerView.reloadData()

    }
}

extension PortfolioCollectionViewCell: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return portfolio?.photos.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.contentMode = .scaleAspectFill
        if let data = portfolio?.photos[index] {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }
        
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
    
//    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
//        delegate?.selectItem(cell: self)
//    }
}
