//
//  MatchesResponse.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

public struct MatchesResponse: Decodable {
    public let matches: AllMatches
    
    init(matches: AllMatches) {
        self.matches = matches
    }
}
