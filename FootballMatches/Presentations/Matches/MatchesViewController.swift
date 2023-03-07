//
//  MatchesViewController.swift
//  FootballMatches
//
//  Created by Hai Pham on 24/02/2023.
//

import UIKit
import AVFoundation
import AVKit
import Combine
import SnapKit
import Domain
import Platform
import JGProgressHUD

class MatchesViewController: UIViewController {
    private let viewModel: MatchesViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(showFilter))
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.add(.valueChanged) { [weak self] _ in
            self?.didPullToRefresh()
        }
        return refreshControl
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: [MatchesViewModel.MatchSegment.previous.getSegmentTitle(),
                                                        MatchesViewModel.MatchSegment.upcoming.getSegmentTitle()])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.add(.valueChanged) { [unowned self] control in
            if let selectedSegment = MatchesViewModel.MatchSegment(rawValue: self.segmentControl.selectedSegmentIndex) {
                self.viewModel.selectMatchSegment(segment: selectedSegment)
            }
        }
        return segmentControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, environment in
            switch CollectionSection(rawValue: sectionIndex) {
            case .team:
                return self.getTeamLayoutSection()
            case .match:
                return self.getMatchLayoutSection()
            default:
                return nil
            }
        }
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(MatchCell.self,
                                forCellWithReuseIdentifier: MatchCell.reuseIdentifier)
        collectionView.register(TeamCell.self,
                                forCellWithReuseIdentifier: TeamCell.reuseIdentifier)
        collectionView.register(MatchesHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MatchesHeaderView.reuseIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.refreshControl = self.refreshControl
        return collectionView
    }()
    private lazy var hud: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading..."
        return hud
    }()

    private var dataSource: UICollectionViewDiffableDataSource<CollectionSection, AnyHashable>!

    // MARK: - Constructors
    init(viewModel: MatchesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureDataSource()
        bindViewModel()
        
        viewModel.viewDidLoad()
    }
    
    // MARK: - Private methods
    private func setupViews() {
        title = "Matches"
        navigationItem.rightBarButtonItem = filterButton
        view.addSubview(collectionView)
        view.addSubview(segmentControl)
        view.backgroundColor = UIColor(red: 239/255,
                                       green: 239/255,
                                       blue: 245/255,
                                       alpha: 1)
    }
    
    private func setupConstraints() {
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeArea.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(20)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    /// Bind view model to this view controller, set up observations
    private func bindViewModel() {
        let mapMatchCellViewModel: (FootballMatch, [FootballTeam], Bool) -> MatchCellViewModel? = {
            match, teams, isPrevious in
            guard let date = match._date else { return nil }
            let homeIcon = teams.first(where: { $0.name == match.home })?.logo
            let awayIcon = teams.first(where: { $0.name == match.away })?.logo
            let hasScheduled = CalendarHelper.shared.hasScheduled(home: match.home,
                                                                  away: match.away,
                                                                  date: date)
            let vm = MatchCellViewModel(home: match.home,
                                        away: match.away,
                                        winner: match.winner,
                                        highlights: match.highlights,
                                        date: date,
                                        homeIcon: homeIcon,
                                        awayIcon: awayIcon,
                                        isPrevious: isPrevious,
                                        hasScheduled: hasScheduled)
            
            vm.teamTapSubject
                .sink { [weak self] team in
                    self?.viewModel.viewTeamDetail(team: team)
                }
                .store(in: &self.cancellables)
            vm.playHighlightSubject
                .sink { [weak self] highlight in
                    let player = AVPlayer(url: URL(string: highlight)!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self?.present(playerViewController, animated: true) {
                        player.play()
                    }
                }
                .store(in: &self.cancellables)
            vm.scheduleSubject
                .sink { [weak self] indexPath, matchCellViewModel in
                    guard let strongSelf = self else { return }
                    if matchCellViewModel.hasScheduled {
                        strongSelf.showAlertWithTitle("This match has been scheduled!")
                    } else {
                        strongSelf.viewModel.setReminderFor(home: matchCellViewModel.home,
                                                            away: matchCellViewModel.away,
                                                            date: matchCellViewModel.date) { [weak self] success, error in
                            guard let strongSelf = self else { return }
                            if success {
                                guard let matchVM = strongSelf.dataSource.itemIdentifier(for: indexPath) as? MatchCellViewModel else {
                                    return
                                }
                                // Update collection view data source after scheduling
                                matchVM.hasScheduled = CalendarHelper.shared.hasScheduled(home: matchVM.home,
                                                                                          away: matchVM.away,
                                                                                          date: matchVM.date)
                                DispatchQueue.main.async {
                                    var newSnapshot = strongSelf.dataSource.snapshot()
                                    newSnapshot.reloadItems([matchVM])
                                    strongSelf.dataSource.apply(newSnapshot)
                                }
                            }
                        }
                    }
                }
                .store(in: &self.cancellables)
            return vm
        }
        
        viewModel.$matchSection.combineLatest(viewModel.$footballTeams)
            .map { matchSection, teams in
                let matchViewModels: [MatchCellViewModel] = matchSection.1.compactMap { match in
                    return mapMatchCellViewModel(match, teams, matchSection.0 == .previous)
                }
                return (matchViewModels, teams)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchViewModels, teams in
                self?.updateSnapshot(teams: teams, matchViewModels: matchViewModels)
            }
            .store(in: &cancellables)
        
        viewModel.$isRefreshing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRefreshing in
                guard let strongSelf = self else {
                    return
                }
                if isRefreshing {
                    strongSelf.refreshControl.beginRefreshing()
                    strongSelf.hud.show(in: strongSelf.view)
                } else {
                    strongSelf.refreshControl.endRefreshing()
                    strongSelf.hud.dismiss()
                }
            }
            .store(in: &cancellables)
        
        viewModel.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let strongSelf = self else {
                    return
                }
                let alertController = UIAlertController(title: "Error",
                                                        message: error.localizedDescription,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK",
                                                        style: .cancel,
                                                        handler: nil))
                strongSelf.present(alertController, animated: true, completion: nil)
            }
            .store(in: &cancellables)
        
        viewModel.selectedTeam
            .receive(on: DispatchQueue.main)
            .sink { [weak self] team in
                guard let strongSelf = self else {
                    return
                }
                let alertController = UIAlertController(title: "Team Detail",
                                                        message: team.name,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK",
                                                        style: .cancel,
                                                        handler: nil))
                strongSelf.present(alertController, animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }
    
    /// Configure data source of collection view
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<CollectionSection, AnyHashable>(
            collectionView: collectionView,
            cellProvider: { [unowned self] collectionView, indexPath, item in
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

                switch section {
                case .team:
                    guard let cell
                            = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCell.reuseIdentifier,
                                                                 for: indexPath) as? TeamCell else {
                        fatalError("Unable to dequeue cell of type MatchCell")
                    }
                    if let team = item as? FootballTeam {
                        cell.configure(teamName: team.name, logo: team.logo)
                    }
                    return cell
                case .match:
                    guard let cell
                            = collectionView.dequeueReusableCell(withReuseIdentifier: MatchCell.reuseIdentifier,
                                                                 for: indexPath) as? MatchCell else {
                        fatalError("Unable to dequeue cell of type MatchCell")
                    }
                    if let cellViewModel = item as? MatchCellViewModel {
                        cell.configure(with: cellViewModel, indexPath: indexPath)
                    }
                    return cell
                }
            })
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let headerView
                    = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                      withReuseIdentifier: MatchesHeaderView.reuseIdentifier,
                                                                      for: indexPath) as? MatchesHeaderView else {
                fatalError("Unable to dequeue header view of type MatchesHeaderView")
            }
            let section = self.dataSource.snapshot()
                .sectionIdentifiers[indexPath.section]
            headerView.configure(section: section.getTitle())
            return headerView
        }
    }
    
    /// Update collection view data source by football teams and footbal matches
    private func updateSnapshot(teams: [FootballTeam], matchViewModels: [MatchCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, AnyHashable>()
        snapshot.appendSections([.team, .match])
        snapshot.appendItems(teams, toSection: .team)
        snapshot.appendItems(matchViewModels, toSection: .match)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    /// Get Horizontal List Layout Section for Football teams
    private func getTeamLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    /// Get Vertical List Layout Section for Football matches
    private func getMatchLayoutSection() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: size)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .fixed(10), trailing: nil, bottom: .fixed(10))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
}

// MARK: - Actions
extension MatchesViewController {
    @objc func showFilter() {
        let alertController = UIAlertController(title: "Filter Matches",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Team Name"
        }
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Filter",
                                                style: .default, handler: { [weak self] _ in
            let team = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.viewModel.fetchMatches(team: team)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    private func didPullToRefresh() {
        self.viewModel.fetchData()
    }
}

extension MatchesViewController {
    enum CollectionSection: Int {
        case team = 0
        case match
        
        func getTitle() -> String {
            switch self {
            case .team:
                return "Teams"
            case .match:
                return "Matches"
            }
        }
    }
}
