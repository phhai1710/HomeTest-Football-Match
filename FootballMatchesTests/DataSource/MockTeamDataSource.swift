//
//  MockTeamDataSource.swift
//  FootballMatchesTests
//
//  Created by Hai Pham on 01/03/2023.
//

import Domain
import Combine

final class MockTeamDataSource: TeamDataSourceProtocol {
    public var localDataSource: Domain.TeamLocalDataSource
    
    public var remoteDataSource: Domain.TeamRemoteDataSource
    
    init(localDataSource: Domain.TeamLocalDataSource, remoteDataSource: Domain.TeamRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
}

final class MockTeamLocalDataSource: Domain.TeamLocalDataSource {
    var mockedValues: [FootballTeam] = []

    public init(){}

    func getFootballTeams() -> AnyPublisher<[FootballTeam], Error> {
        return Just(mockedValues)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveFootballTeams(teams: [FootballTeam]) {
        mockedValues.removeAll()
        mockedValues.append(contentsOf: teams)
    }
    
    func deleteFootballTeams() {
        mockedValues.removeAll()
    }
}

final class MockTeamRemoteDataSource: Domain.TeamRemoteDataSource {
    var mockedValues: [FootballTeam] = []

    public init(){}

    func getFootballTeams() -> AnyPublisher<[FootballTeam], Error> {
        return Just(mockedValues)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
