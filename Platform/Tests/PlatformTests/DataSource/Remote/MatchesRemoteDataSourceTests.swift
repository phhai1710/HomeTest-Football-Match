import XCTest
import Domain

@testable import Platform

final class MatchesRemoteDataSourceTests: XCTestCase {
    static var dataSource: MatchesRemoteDataSource!

    override class func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        let service = URLSessionService(urlSession: urlSession, baseURLString: "")
        
        MatchesRemoteDataSourceTests.dataSource = URLSessionMatchesRemoteDataSource(service: service)
    }
    
    func testRemoteGetMatchesSuccess() {
        let response =
                      """
                      {
                        "matches": {
                          "previous": [
                            {
                              "date": "2022-04-23T18:00:00.000Z",
                              "description": "Team Cool Eagles vs. Team Red Dragons",
                              "home": "Team Cool Eagles",
                              "away": "Team Red Dragons",
                              "winner": "Team Red Dragons",
                              "highlights": "https://tstzj.s3.amazonaws.com/highlights.mp4"
                            }
                          ],
                          "upcoming": [
                            {
                              "date": "2022-08-13T20:00:00.000Z",
                              "description": "Team Cool Eagles vs. Team Serious Lions",
                              "home": "Team Cool Eagles",
                              "away": "Team Serious Lions"
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
        
        let matches = try? awaitPublisher(MatchesRemoteDataSourceTests.dataSource.getFootballMatches())
        XCTAssertEqual(matches?.incoming.count, 1)
        XCTAssertEqual(matches?.previous.count, 1)
    }
    
    func testRemoteGetMatchesMissingUpcoming() {
        let response =
                      """
                      {
                        "matches": {
                          "previous": [
                            {
                              "date": "2022-04-23T18:00:00.000Z",
                              "description": "Team Cool Eagles vs. Team Red Dragons",
                              "home": "Team Cool Eagles",
                              "away": "Team Red Dragons",
                              "winner": "Team Red Dragons",
                              "highlights": "https://tstzj.s3.amazonaws.com/highlights.mp4"
                            }
                          ],
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
            _ = try awaitPublisher(MatchesRemoteDataSourceTests.dataSource.getFootballMatches())
        } catch let _error {
            error = _error
        }
        XCTAssertNotNil(error)
    }
    
    func testRemoteGetMatchesMissingKey() {
        let response =
                      """
                      {
                        "matches": {
                          "previous": [
                            {
                              "date": "2022-04-23T18:00:00.000Z",
                              "description": "Team Cool Eagles vs. Team Red Dragons",
                              "away": "Team Red Dragons",
                              "winner": "Team Red Dragons",
                              "highlights": "https://tstzj.s3.amazonaws.com/highlights.mp4"
                            }
                          ],
                          "upcoming": [
                            {
                              "date": "2022-08-13T20:00:00.000Z",
                              "description": "Team Cool Eagles vs. Team Serious Lions",
                              "away": "Team Serious Lions"
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
            _ = try awaitPublisher(MatchesRemoteDataSourceTests.dataSource.getFootballMatches())
        } catch let _error {
            error = _error
        }
        XCTAssertNotNil(error)
    }
}
