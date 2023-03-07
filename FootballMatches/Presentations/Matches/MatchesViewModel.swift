//
//  MatchesViewModel.swift
//  FootballMatches
//
//  Created by Hai Pham on 24/02/2023.
//

import Foundation
import Combine
import Domain

extension MatchesViewModel {
    enum MatchSegment: Int {
        case previous = 0
        case upcoming = 1
        
        func getSegmentTitle() -> String {
            switch self {
            case .previous:
                return "Previous"
            case .upcoming:
                return "Upcoming"
            }
        }
    }
}

final class MatchesViewModel: ObservableObject {
    // Dependencies
    private let matchesDataSource: MatchesDataSourceProtocol
    private let teamDataSource: TeamDataSourceProtocol
    
    @Published var matchSection: (MatchSegment, [FootballMatch]) = (.previous, [])
    @Published private var origMatches: (previous: [FootballMatch], incoming: [FootballMatch]) = ([],[])
    @Published var footballTeams: [FootballTeam] = []
    @Published var isRefreshing = false
    @Published var selectedMatchSegment: MatchSegment = .previous
    @Published var filteredTeam: String = ""
    
    let error = PassthroughSubject<Error, Never>()
    let selectedTeam = PassthroughSubject<FootballTeam, Never>()

    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Constructors
    init(matchesDataSource: MatchesDataSourceProtocol, teamDataSource: TeamDataSourceProtocol) {
        self.matchesDataSource = matchesDataSource
        self.teamDataSource = teamDataSource
        
        observe()
    }
    
    // MARK: - Private methods
    /// Sets up all the observations
    private func observe() {
        $origMatches.combineLatest($selectedMatchSegment, $filteredTeam)
            .sink(receiveValue: { [weak self] origMatches, selectedMatchSegment, filteredTeam in
                var matches = [FootballMatch]()
                switch selectedMatchSegment {
                case .previous:
                    matches = origMatches.previous
                case .upcoming:
                    matches = origMatches.incoming
                }
                
                matches = matches.filter { filteredTeam == "" ||
                    $0.home.lowercased().contains(filteredTeam.lowercased()) ||
                    $0.away.lowercased().contains(filteredTeam.lowercased()) }
                
                self?.matchSection = (selectedMatchSegment, matches)
                
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Public methods
    func viewDidLoad() {
        // TODO: Remove hardcode of waiting for network monitoring
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.fetchData()
        }
    }
    
    /// Fetches all initial data
    func fetchData() {
        isRefreshing = true

        let matchesPublisher: AnyPublisher<(previous: [FootballMatch], incoming: [FootballMatch]), Error>
        let teamPublisher: AnyPublisher<[FootballTeam], Error>
        let isNetworkAvailable = ReachabilityService.shared.isNetworkAvailable.value
        if isNetworkAvailable {
            matchesPublisher = matchesDataSource.remoteDataSource.getFootballMatches()
            teamPublisher = teamDataSource.remoteDataSource.getFootballTeams()
        } else {
            matchesPublisher = matchesDataSource.localDataSource.getFootballMatches()
            teamPublisher = teamDataSource.localDataSource.getFootballTeams()
        }
        matchesPublisher.combineLatest(teamPublisher)
            .sink { [weak self] completion in
                self?.isRefreshing = false

                switch completion {
                case .failure(let error):
                    debugPrint(error)
                    self?.error.send(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] matches, teams in
                guard let strongSelf = self else { return }
                strongSelf.footballTeams = teams
                strongSelf.origMatches = (matches.previous, matches.incoming)
                if isNetworkAvailable {
                    strongSelf.matchesDataSource.localDataSource.deleteFootballMatches()
                    strongSelf.matchesDataSource.localDataSource.saveFootballMatches(previous: matches.previous,
                                                                                     incoming: matches.incoming)
                    strongSelf.teamDataSource.localDataSource.deleteFootballTeams()
                    strongSelf.teamDataSource.localDataSource.saveFootballTeams(teams: teams)
                }
            }.store(in: &cancellables)
    }
    
    /// Filters the football matches based on the entered team
    func fetchMatches(team: String? = nil) {
        let team = team?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.filteredTeam = team
    }
    
    /// Selects the match segment to display (previous or upcoming)
    func selectMatchSegment(segment: MatchSegment) {
        self.selectedMatchSegment = segment
    }
    
    func viewTeamDetail(team: String) {
        if let teamDetail = footballTeams.first(where: { $0.name == team}) {
            selectedTeam.send(teamDetail)
        } else {
            let userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Can't find team detail"]
            let err = NSError(domain: "UnavailableErrorDomain", code: 404, userInfo: userInfo)
            error.send(err)
        }
    }
    
    /**
     Set reminder for a match
     
     - parameters:
         - home:  Name of home team
         - away:  Name of away team
         - date: Time of the reminder
         - completion: Callback after setting reminder. It may throw error if the app doesn't have permission
     */
    func setReminderFor(home: String, away: String, date: Date,
                        completion: @escaping (Bool, Error?) -> ()) {
        CalendarHelper.shared.setReminderForMatch(home: home, away: away, date: date, completion: completion)
    }
}
