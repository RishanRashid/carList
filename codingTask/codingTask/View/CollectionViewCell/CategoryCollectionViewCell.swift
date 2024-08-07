//
//  CategoryCollectionViewCell.swift
//  codingTask
//
//  Created by Allnet Systems on 8/7/24.
//

import UIKit
import UIView_Shimmer

class CategoryCollectionViewCell: UICollectionViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var barView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(isSelected: Bool) {
        titleButton.setTitleColor(isSelected ? .orange : .gray, for: .normal)
        barView.backgroundColor = isSelected ? .orange : .gray
    }

    var shimmeringAnimatedItems: [UIView] {
        return [barView, titleButton]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setTemplateWithSubviews(false)
    }
}
