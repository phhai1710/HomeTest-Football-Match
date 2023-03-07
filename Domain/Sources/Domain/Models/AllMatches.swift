//
//  AllMatches.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

public struct AllMatches: Decodable {
    public let previous: [FootballMatch]
    public let upcoming: [FootballMatch]
    
    init(previous: [FootballMatch], upcoming: [FootballMatch]) {
        self.previous = previous
        self.upcoming = upcoming
    }
}
