//
//  TeamDataSourceProtocol.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

public protocol TeamDataSourceProtocol {
    var localDataSource: TeamLocalDataSource { get }
    var remoteDataSource: TeamRemoteDataSource { get }
}
