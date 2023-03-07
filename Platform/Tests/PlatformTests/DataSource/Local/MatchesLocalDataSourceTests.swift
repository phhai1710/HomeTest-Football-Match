//
//  MatchesLocalDataSourceTests.swift
//  
//
//  Created by Hai Pham on 01/03/2023.
//

import XCTest
import Domain

@testable import Platform

final class MatchesLocalDataSourceTests: XCTestCase {
    let dataSource: MatchesLocalDataSource = CoreDataMatchesLocalDataSource()
    
    func testSaveAndGetMatches() {
        let match = FootballMatch(home: "home",
                                  away: "away",
                                  description: "desc",
                                  winner: "winner",
                                  highlights: "highlighted",
                                  date: "date")
        dataSource.saveFootballMatches(previous: [match], incoming: [match])

        let teams = try? awaitPublisher(dataSource.getFootballMatches())
        XCTAssertEqual(teams?.incoming.count, 1)
        XCTAssertEqual(teams?.previous.count, 1)
    }
    
    func testSaveAndDeleteMatches() {
        let match = FootballMatch(home: "home",
                                  away: "away",
                                  description: "desc",
                                  winner: "winner",
                                  highlights: "highlighted",
                                  date: "date")
        dataSource.saveFootballMatches(previous: [match], incoming: [match])
        dataSource.deleteFootballMatches()
        let teams = try? awaitPublisher(dataSource.getFootballMatches())
        XCTAssertEqual(teams?.incoming.count, 0)
        XCTAssertEqual(teams?.previous.count, 0)
    }
    
    override func tearDown() {
        dataSource.deleteFootballMatches()
    }
}
