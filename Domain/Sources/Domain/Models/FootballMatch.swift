//
//  FootballMatch.swift
//
//  Created by Hai Pham on 23/02/2023.
//

public struct FootballMatch: Decodable, Hashable {
    public let home: String
    public let away: String
    public let description: String
    public let winner: String?
    public let highlights: String?
    public let date: String
    
    public init(home: String, away: String, description: String, winner: String?, highlights: String?, date: String) {
        self.home = home
        self.away = away
        self.description = description
        self.winner = winner
        self.highlights = highlights
        self.date = date
    }
}
