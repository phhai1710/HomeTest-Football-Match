//
//  FootballTeam.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

public struct FootballTeam: Decodable, Hashable {
    public let id: String
    public let name: String
    public let logo: String
    
    public init(id: String, name: String, logo: String) {
        self.id = id
        self.name = name
        self.logo = logo
    }
}
