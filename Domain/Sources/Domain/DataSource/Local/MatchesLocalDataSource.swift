//
//  MatchesLocalDataSource.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//
import Combine

/// Defining interface of local data source related to football match
public protocol MatchesLocalDataSource {
    /**
     Fetches all football matches in local data source

     - Returns: Previous and upcoming matches
     */
    func getFootballMatches() -> AnyPublisher<(previous: [FootballMatch], incoming: [FootballMatch]), Error>
    
    /// Save football matches into local data source
    func saveFootballMatches(previous: [FootballMatch], incoming: [FootballMatch])
    
    /// Delete all football matches in local data source
    func deleteFootballMatches()
}
