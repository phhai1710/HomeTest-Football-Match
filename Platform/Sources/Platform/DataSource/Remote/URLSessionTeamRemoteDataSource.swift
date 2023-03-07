//
//  URLSessionTeamRemoteDataSource.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

import Domain
import Foundation
import Combine

/// Implementation of TeamRemoteDataSource using URLSession
final class URLSessionTeamRemoteDataSource: TeamRemoteDataSource {
    
    private let service: URLSessionService

    init(service: URLSessionService = .shared) {
        self.service = service
    }
    
    /**
     Fetches football teams from server

     - Returns: All football teams
     */
    func getFootballTeams() -> AnyPublisher<[FootballTeam], Error> {
        return service.dataTaskPublisher(for: "/teams")
            .map { $0.data }
            .decode(type: TeamsResponse.self, decoder: JSONDecoder())
            .map { $0.teams }
            .eraseToAnyPublisher()
    }
}
