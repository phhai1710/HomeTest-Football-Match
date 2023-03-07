//
//  TeamCell.swift
//  FootballMatches
//
//  Created by Hai Pham on 03/03/2023.
//

import UIKit
import Kingfisher

class TeamCell: UICollectionViewCell {
    static let reuseIdentifier = "TeamCell"
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel])
        stackView.axis = .vertical
        stackView.backgroundColor = .white
        stackView.layer.masksToBounds = false
        stackView.layer.cornerRadius = 12
        stackView.clipsToBounds = true
        
        return stackView
    }()
    
    // MARK: - Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stackView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.imageView.snp.makeConstraints { make in
            make.width.equalTo(imageView.snp.height)
        }
    }
    
    // MARK: - Public methods
    func configure(teamName: String, logo: String) {
        nameLabel.text = teamName
        imageView.kf.setImage(with: URL(string: logo))
    }
}
