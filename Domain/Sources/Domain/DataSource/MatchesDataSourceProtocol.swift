//
//  MatchesDataSourceProtocol.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

public protocol MatchesDataSourceProtocol {
    var localDataSource: MatchesLocalDataSource { get }
    var remoteDataSource: MatchesRemoteDataSource { get }
}
