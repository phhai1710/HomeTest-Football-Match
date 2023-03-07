//
//  MatchCellViewModel.swift
//  FootballMatches
//
//  Created by Hai Pham on 02/03/2023.
//

import Foundation
import Combine

class MatchCellViewModel: Hashable {
    
    let home: String
    let away: String
    let winner: String?
    let highlights: String?
    let date: Date
    let homeIcon: String?
    let awayIcon: String?
    let isPrevious: Bool
    var hasScheduled: Bool
    let scheduleSubject = PassthroughSubject<(IndexPath, MatchCellViewModel), Never>()
    let teamTapSubject = PassthroughSubject<String, Never>()
    let playHighlightSubject = PassthroughSubject<String, Never>()
    
    init(home: String, away: String, winner: String?, highlights: String?, date: Date,
         homeIcon: String?, awayIcon: String?, isPrevious: Bool, hasScheduled: Bool) {
        self.home = home
        self.away = away
        self.winner = winner
        self.highlights = highlights
        self.date = date
        self.homeIcon = homeIcon
        self.awayIcon = awayIcon
        self.isPrevious = isPrevious
        self.hasScheduled = hasScheduled
    }
    
    static func == (lhs: MatchCellViewModel, rhs: MatchCellViewModel) -> Bool {
        return lhs.home == rhs.home && lhs.away == rhs.away
        && lhs.winner == rhs.winner && lhs.date == rhs.date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(home)
        hasher.combine(away)
        hasher.combine(winner)
        hasher.combine(date)
    }
}
