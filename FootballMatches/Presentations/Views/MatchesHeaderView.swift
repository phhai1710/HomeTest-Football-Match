//
//  MatchesHeaderView.swift
//  FootballMatches
//
//  Created by Hai Pham on 24/02/2023.
//

import UIKit
import SnapKit

class MatchesHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "MatchesHeaderView"
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configure(section: String) {
        self.titleLabel.text = section
    }
}
