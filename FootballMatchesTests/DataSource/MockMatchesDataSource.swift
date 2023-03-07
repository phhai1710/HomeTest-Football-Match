//
//  MockMatchesDataSource.swift
//  FootballMatchesTests
//
//  Created by Hai Pham on 01/03/2023.
//

import Domain
import Combine

final class MockMatchesDataSource: MatchesDataSourceProtocol {
    public var localDataSource: Domain.MatchesLocalDataSource
    
    public var remoteDataSource: Domain.MatchesRemoteDataSource
    
    init(localDataSource: Domain.MatchesLocalDataSource, remoteDataSource: Domain.MatchesRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
}

final class MockMatchesLocalDataSource: Domain.MatchesLocalDataSource {
    var mockedPrevious = [FootballMatch]()
    var mockedUpcoming = [FootballMatch]()

    public init(){}

    func getFootballMatches() -> AnyPublisher<(previous: [FootballMatch], incoming: [FootballMatch]), Error> {
        return Just((mockedPrevious, mockedUpcoming))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveFootballMatches(previous: [FootballMatch], incoming: [FootballMatch]) {
        mockedPrevious.removeAll()
        mockedUpcoming.removeAll()
        mockedPrevious.append(contentsOf: previous)
        mockedUpcoming.append(contentsOf: incoming)
    }
    
    func deleteFootballMatches() {
        mockedPrevious.removeAll()
        mockedUpcoming.removeAll()
    }
}

final class MockMatchesRemoteDataSource: Domain.MatchesRemoteDataSource {
    var mockedPrevious = [FootballMatch]()
    var mockedUpcoming = [FootballMatch]()
    
    public init(){}

    func getFootballMatches() -> AnyPublisher<(previous: [FootballMatch], incoming: [FootballMatch]), Error> {
        return Just((mockedPrevious, mockedUpcoming))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
