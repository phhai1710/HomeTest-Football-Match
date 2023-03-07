//
//  MatchCell.swift
//  Football
//
//  Created by Hai Pham on 23/02/2023.
//

import UIKit
import SnapKit
import Domain
import Combine
import Kingfisher

class MatchCell: UICollectionViewCell {
    static let reuseIdentifier = "MatchCell"

    private var viewModel: MatchCellViewModel?
    private var indexPath: IndexPath?
    private lazy var homeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    private lazy var awayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = dateLabel.font.withSize(13)
        dateLabel.textAlignment = .center
        return dateLabel
    }()
    private lazy var logoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [homeStackView, vsImageView, awayStackView])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoStackView, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.backgroundColor = .white
        stackView.layer.masksToBounds = false
        stackView.layer.cornerRadius = 12
        stackView.clipsToBounds = true
        return stackView
    }()
    private lazy var homeImage: UIImageView = {
        let homeImage = UIImageView()
        homeImage.contentMode = .scaleAspectFit
        homeImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHomeTeam))
        homeImage.addGestureRecognizer(tapGesture)
        return homeImage
    }()
    private lazy var homeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [homeImage, homeLabel])
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var awayImage: UIImageView = {
        let awayImage = UIImageView()
        awayImage.contentMode = .scaleAspectFit
        awayImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAwayTeam))
        awayImage.addGestureRecognizer(tapGesture)
        return awayImage
    }()
    private lazy var awayStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [awayImage, awayLabel])
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var vsImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "ic_vs")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var topRightButton: UIButton = {
        let button = UIButton(type: .system)
        button.add(.touchUpInside) { [unowned self] _ in
            if let viewModel = self.viewModel {
                if viewModel.isPrevious {
                    if let highlights = viewModel.highlights {
                        self.viewModel?.playHighlightSubject.send(highlights)
                    }
                } else {
                    if let indexPath = indexPath {
                        self.viewModel?.scheduleSubject.send((indexPath, viewModel))
                    }
                }
            }
        }
        return button
    }()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerStackView)
        contentView.addSubview(topRightButton)
        contentView.backgroundColor = .clear
        homeStackView.snp.makeConstraints { make in
            make.width.equalTo(awayStackView.snp.width)
        }
        homeImage.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.height.equalTo(awayImage.snp.height)
        }
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        vsImageView.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        topRightButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.top.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        awayImage.kf.cancelDownloadTask()
        homeImage.kf.cancelDownloadTask()
        cancellables.removeAll()
    }
    
    // MARK: - Public methods
    func configure(with viewModel: MatchCellViewModel, indexPath: IndexPath) {
        self.viewModel = viewModel
        self.indexPath = indexPath
        homeLabel.text = viewModel.home
        awayLabel.text = viewModel.away
        homeLabel.textColor = viewModel.winner == viewModel.home ? .red : .systemBlue
        awayLabel.textColor = viewModel.winner == viewModel.away ? .red : .systemBlue
        
        configDate(date: viewModel.date)
        configIcon(homeIcon: viewModel.homeIcon, awayIcon: viewModel.awayIcon)
        configTopRightButton(isPrevious: viewModel.isPrevious, isScheduled: viewModel.hasScheduled)
    }
    
    // MARK: - Private methods
    private func configIcon(homeIcon: String?, awayIcon: String?) {
        let processor = DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))
        let resizeOption = KingfisherOptionsInfoItem.processor(processor)

        if let homeIcon = homeIcon {
            homeImage.kf.setImage(with: URL(string: homeIcon), options: [resizeOption])
        } else {
            homeImage.image = UIImage(systemName: "person.circle.fill")
        }
        if let awayIcon = awayIcon {
            awayImage.kf.setImage(with: URL(string: awayIcon), options: [resizeOption])
        } else {
            awayImage.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    private func configDate(date: Date?) {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd 'at' HH:mm"
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
    }
    
    private func configTopRightButton(isPrevious: Bool, isScheduled: Bool) {
        if isPrevious {
            topRightButton.setImage(UIImage(systemName: "play.rectangle.on.rectangle.fill"), for: .normal)
        } else {
            let icon = UIImage(systemName:  isScheduled ? "checkmark.seal.fill" : "checkmark.icloud")
            topRightButton.setImage(icon, for: .normal)
        }
    }
    
}

extension MatchCell {
    @objc func didTapHomeTeam() {
        if let home = viewModel?.home {
            viewModel?.teamTapSubject.send(home)
        }
        print("didTapHomeTeam")
    }
    
    @objc func didTapAwayTeam() {
        if let away = viewModel?.away {
            viewModel?.teamTapSubject.send(away)
        }
        print("didTapAwayTeam")
    }
}
