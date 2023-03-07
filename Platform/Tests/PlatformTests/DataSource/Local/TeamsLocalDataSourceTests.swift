//
//  TeamsLocalDataSourceTests.swift
//  
//
//  Created by Hai Pham on 01/03/2023.
//

import XCTest
import Domain

@testable import Platform

final class TeamsLocalDataSourceTests: XCTestCase {
    let dataSource: TeamLocalDataSource = CoreDataTeamLocalDataSource()
    
    func testSaveAndGetMatches() {
        let team = FootballTeam(id: "1", name: "name", logo: "logo")
        dataSource.saveFootballTeams(teams: [team])

        let teams = try? awaitPublisher(dataSource.getFootballTeams())
        XCTAssertEqual(teams?.count, 1)
    }
    
    func testSaveAndDeleteMatches() {
        let team = FootballTeam(id: "1", name: "name", logo: "logo")
        dataSource.saveFootballTeams(teams: [team])
        dataSource.deleteFootballTeams()
        let teams = try? awaitPublisher(dataSource.getFootballTeams())
        XCTAssertEqual(teams?.count, 0)
    }
    
    override func tearDown() {
        dataSource.deleteFootballTeams()
    }
}
