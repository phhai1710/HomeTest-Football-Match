//
//  TeamDataSource.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

import Foundation
import Domain

public final class TeamDataSource: TeamDataSourceProtocol {
    public var localDataSource: Domain.TeamLocalDataSource = {
        return CoreDataTeamLocalDataSource()
    }()
    
    public var remoteDataSource: Domain.TeamRemoteDataSource = {
        return URLSessionTeamRemoteDataSource()
    }()
    
    public init(){}
}

