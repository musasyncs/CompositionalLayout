//
//  MyCollectionViewCell.swift
//  CompositionalLayout
//
//  Created by Ewen on 2021/10/6.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    static let identifier = "MyCollectionViewCell"
    
    var imageURL: URL!
    
    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode   = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
}
