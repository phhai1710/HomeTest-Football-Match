//
//  URLSessionMatchesRemoteDataSource.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

import Domain
import Foundation
import Combine

/// Implementation of MatchesRemoteDataSource using URLSession
final class URLSessionMatchesRemoteDataSource: MatchesRemoteDataSource {
    private let service: URLSessionService

    init(service: URLSessionService = .shared) {
        self.service = service
    }
    
    /**
     Fetches football matches from server

     - Returns: All previous and upcoming matches
     */
    func getFootballMatches() -> AnyPublisher<(previous: [FootballMatch], incoming: [FootballMatch]), Error> {
        return service.dataTaskPublisher(for: "/teams/matches")
            .map { $0.data }
            .decode(type: MatchesResponse.self, decoder: JSONDecoder())
            .map { ($0.matches.previous, $0.matches.upcoming) }
            .eraseToAnyPublisher()
    }
}
