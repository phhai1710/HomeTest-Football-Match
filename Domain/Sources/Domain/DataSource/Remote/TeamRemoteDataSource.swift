//
//  TeamRemoteDataSource.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

import Combine

/// Defining interface of remote data source related to football match
public protocol TeamRemoteDataSource {
    /**
     Fetches all football teams in remote data source

     - Returns: Previous and upcoming matches
     */
    func getFootballTeams() -> AnyPublisher<[FootballTeam], Error>
}
