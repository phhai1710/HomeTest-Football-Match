//
//  FootballMatchesTests.swift
//  FootballMatchesTests
//
//  Created by Hai Pham on 23/02/2023.
//

import Domain
import Platform
import XCTest
import Combine

@testable import FootballMatches

final class MatchesViewModelTest: XCTestCase {
    private var viewModel: MatchesViewModel!
    private var matchesLocalDataSource: MockMatchesLocalDataSource!
    private var matchesRemoteDataSource: MockMatchesRemoteDataSource!
    private var teamLocalDataSource: MockTeamLocalDataSource!
    private var teamRemoteDataSource: MockTeamRemoteDataSource!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        matchesLocalDataSource = MockMatchesLocalDataSource()
        matchesRemoteDataSource = MockMatchesRemoteDataSource()
        teamLocalDataSource = MockTeamLocalDataSource()
        teamRemoteDataSource = MockTeamRemoteDataSource()
        viewModel = MatchesViewModel(matchesDataSource: MockMatchesDataSource(localDataSource: matchesLocalDataSource,
                                                                              remoteDataSource: matchesRemoteDataSource),
                                     teamDataSource: MockTeamDataSource(localDataSource: teamLocalDataSource,
                                                                        remoteDataSource: teamRemoteDataSource))
        super.setUp()
    }
    
    func testFetchData() {
        let expectation = XCTestExpectation(description: "Fetch matches called")
        let expectation2 = XCTestExpectation(description: "Fetch teams called")
        let match = self.getMockMatch()
        matchesLocalDataSource.mockedPrevious = [match]
        matchesLocalDataSource.mockedUpcoming = [match]
        matchesRemoteDataSource.mockedPrevious = [match]
        matchesRemoteDataSource.mockedUpcoming = [match]

        let team = getMockTeam()
        teamLocalDataSource.mockedValues = [team]
        teamRemoteDataSource.mockedValues = [team]
        
        viewModel.$matchSection.dropFirst()
            .sink { _, matches in
                XCTAssertEqual(matches.count, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        
        viewModel.$footballTeams
            .dropFirst()
            .sink { teams in
                XCTAssertEqual(teams.count, 1)
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        
        viewModel.fetchData()
        
        wait(for: [expectation, expectation2], timeout: 10)
    }
    
    func testFilterTeam() {
        let expectation = XCTestExpectation(description: "Filter matches called")
        expectation.expectedFulfillmentCount = 2
        let match = self.getMockMatch(home: "home")
        let match2 = self.getMockMatch(home: "home2")
        matchesLocalDataSource.mockedPrevious = [match, match2]
        matchesLocalDataSource.mockedUpcoming = [match, match2]
        matchesRemoteDataSource.mockedPrevious = [match, match2]
        matchesRemoteDataSource.mockedUpcoming = [match, match2]
        
        viewModel.fetchData()

        var values = [Int]()
        viewModel.$matchSection.dropFirst()
            .sink { _, matches in
                values.append(matches.count)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        
        viewModel.fetchMatches(team: "home2")
        viewModel.fetchMatches()
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(values, [1, 2])
    }
    
    func testIsRefreshing() {
        let expectation = XCTestExpectation(description: "Check is refreshing")
        expectation.expectedFulfillmentCount = 2
        var values = [Bool]()
        viewModel.$isRefreshing.dropFirst()
            .sink { isRefreshing in
                values.append(isRefreshing)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.fetchData()
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(values, [true, false])
    }
    
    func testChangeMatchSegment() {
        let expectation = XCTestExpectation(description: "Fetch matches called")
        let match = self.getMockMatch()
        matchesLocalDataSource.mockedPrevious = [match]
        matchesLocalDataSource.mockedUpcoming = [match, match]
        matchesRemoteDataSource.mockedPrevious = [match]
        matchesRemoteDataSource.mockedUpcoming = [match, match]
        
        viewModel.fetchData()

        viewModel.$matchSection.dropFirst()
            .sink { section, matches in
                XCTAssertEqual(section, MatchesViewModel.MatchSegment.upcoming)
                XCTAssertEqual(matches.count, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.selectMatchSegment(segment: .upcoming)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testViewTeamDetailSuccess() {
        let expectation = XCTestExpectation(description: "View team detail called")

        let team = getMockTeam(name: "test")
        teamLocalDataSource.mockedValues = [team]
        teamRemoteDataSource.mockedValues = [team]
        
        viewModel.fetchData()
        
        viewModel.selectedTeam
            .sink { team in
                XCTAssertEqual(team.name, "test")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.viewTeamDetail(team: "test")
        wait(for: [expectation], timeout: 10)
    }
    
    func testViewTeamDetailFailed() {
        let expectation = XCTestExpectation(description: "View team detail called")

        let team = getMockTeam(name: "test")
        teamLocalDataSource.mockedValues = [team]
        teamRemoteDataSource.mockedValues = [team]
        
        viewModel.fetchData()
        
        viewModel.error
            .sink(receiveValue: { error in
                expectation.fulfill()
                
            })
            .store(in: &cancellables)
        
        viewModel.viewTeamDetail(team: "test2")
        wait(for: [expectation], timeout: 10)
    }

    func getMockMatch(home: String = "home") -> FootballMatch {
        return FootballMatch(home: home,
                             away: "away",
                             description: "desc",
                             winner: "winner",
                             highlights: "highlighted",
                             date: "date")
    }
    
    func getMockTeam(name: String = "name") -> FootballTeam {
        return FootballTeam(id: "1", name: name, logo: "logo")
    }
}
