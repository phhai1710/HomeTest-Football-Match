//
//  TeamsRemoteDataSourceTests.swift
//  
//
//  Created by Hai Pham on 01/03/2023.
//

import XCTest
import Domain

@testable import Platform

final class TeamsRemoteDataSourceTests: XCTestCase {
    static var dataSource: TeamRemoteDataSource!

    override class func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        let service = URLSessionService(urlSession: urlSession, baseURLString: "")
        
        TeamsRemoteDataSourceTests.dataSource = URLSessionTeamRemoteDataSource(service: service)
    }
    
    func testRemoteGetTeams() {
        let response =
                      """
                      {
                        "teams": [
                            {
                              "id": "767ec50c-7fdb-4c3d-98f9-d6727ef8252b",
                              "name": "Team Red Dragons",
                              "logo": "https://tstzj.s3.amazonaws.com/dragons.png"
                            }
                        ]
                      }
                      """
        let data = response.data(using: .utf8)!
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), data)
        }
        
        let teams = try? awaitPublisher(TeamsRemoteDataSourceTests.dataSource.getFootballTeams())
        XCTAssertEqual(teams?.count, 1)
    }
    
    func testRemoteGetEmptyTeams() {
        let response =
                      """
                      {
                        "teams": []
                      }
                      """
        let data = response.data(using: .utf8)!
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), data)
        }
        
        let teams = try? awaitPublisher(TeamsRemoteDataSourceTests.dataSource.getFootballTeams())
        XCTAssertEqual(teams?.count, 0)
    }
    
    func testRemoteGetTeamsMissingKey() {
        let response =
                      """
                      {
                        "teams": [
                            {
                              "id": "767ec50c-7fdb-4c3d-98f9-d6727ef8252b",
                              "logo": "https://tstzj.s3.amazonaws.com/dragons.png"
                            }
                          ]
                        }
                      }
                      """
        let data = response.data(using: .utf8)!
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), data)
        }
        var error: Error?
        do {
            _ = try awaitPublisher(TeamsRemoteDataSourceTests.dataSource.getFootballTeams())
        } catch let _error {
            error = _error
        }
        XCTAssertNotNil(error)
    }
}
