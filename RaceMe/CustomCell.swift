//
//  CustomCell.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 4/6/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Neon

class CustomCell: UICollectionViewCell {
    
    var slide: Slide? {
        didSet {
            titleLabel.text = slide?.title
            descLabel.text = slide?.description
            imageView.image = slide?.image
        }
    }
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Semibold", size: 24)
        return label
    }()
    
    fileprivate let descLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "OpenSans", size: 17)
        return label
    }()
    
    fileprivate let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomCell {
    
    fileprivate func setupViews() {
        backgroundColor = primaryColor
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        titleLabel.anchorToEdge(.top, padding: 35, width: frame.width, height: 30)
        descLabel.align(.underCentered, relativeTo: titleLabel, padding: 10, width: frame.width - 40, height: 50)
        imageView.align(.underCentered, relativeTo: descLabel, padding: 0, width: descLabel.width, height: frame.height - 80)
    }
}
