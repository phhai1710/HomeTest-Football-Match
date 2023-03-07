//
//  MatchesDataSource.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

import Foundation
import Domain

public final class MatchesDataSource: MatchesDataSourceProtocol {
    public var localDataSource: Domain.MatchesLocalDataSource = {
        return CoreDataMatchesLocalDataSource()
    }()
    
    public var remoteDataSource: Domain.MatchesRemoteDataSource = {
        return URLSessionMatchesRemoteDataSource()
    }()
    
    public init(){}
}

