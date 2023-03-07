//
//  MatchesRemoteDataSource.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

import Combine

/// Defining interface of remote data source related to football match
public protocol MatchesRemoteDataSource {
    /**
     Fetches all football matches in remote data source

     - Returns: Previous and upcoming matches
     */
    func getFootballMatches() -> AnyPublisher<(previous: [FootballMatch], incoming: [FootballMatch]), Error>
}
