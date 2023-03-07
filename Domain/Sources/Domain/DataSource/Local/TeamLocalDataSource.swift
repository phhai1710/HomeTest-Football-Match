//
//  TeamLocalDataSource.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

import Combine

/// Defining interface of local data source related to football team
public protocol TeamLocalDataSource {
    /**
     Fetches all football teams in local data source

     - Returns: Previous and upcoming matches
     */
    func getFootballTeams() -> AnyPublisher<[FootballTeam], Error>
    /// Save football teams into local data source
    func saveFootballTeams(teams: [FootballTeam])
    /// Delete all football teams in local data source
    func deleteFootballTeams()
}
