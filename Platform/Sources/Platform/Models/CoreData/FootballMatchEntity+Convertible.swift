//
//  FootballMatchEntity+Convertible.swift
//  
//
//  Created by Hai Pham on 27/02/2023.
//

import Foundation
import Domain
import CoreData

extension FootballMatchEntity: DomainConvertible {
    func asDomain() -> FootballMatch? {
        if let home = self.home,
           let away = self.away,
           let desc = self.desc,
           let date = self.date {
            return FootballMatch(home: home,
                                 away: away,
                                 description: desc,
                                 winner: self.winner,
                                 highlights: self.highlights,
                                 date: date)
        }
        return nil
    }
}

extension FootballMatch: CoreDataRepresentable {
    func asCoreData(context: NSManagedObjectContext) -> FootballMatchEntity {
        let entity = FootballMatchEntity(context: context)
        entity.home = self.home
        entity.away = self.away
        entity.desc = self.description
        entity.winner = self.winner
        entity.highlights = self.highlights
        entity.date = self.date
        return entity
    }
}
