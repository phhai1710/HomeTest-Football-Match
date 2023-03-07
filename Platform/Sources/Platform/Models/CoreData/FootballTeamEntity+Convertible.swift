//
//  FootballTeamEntity+Convertible.swift.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

import Foundation
import Domain
import CoreData

extension FootballTeamEntity: DomainConvertible {
    func asDomain() -> FootballTeam? {
        if let id = self.id,
           let name = self.name,
           let logo = self.logo {
            return FootballTeam(id: id, name: name, logo: logo)
        }
        return nil
    }
}

extension FootballTeam: CoreDataRepresentable {
    func asCoreData(context: NSManagedObjectContext) -> FootballTeamEntity {
        let entity = FootballTeamEntity(context: context)
        entity.id = self.id
        entity.name = self.name
        entity.logo = self.logo
        return entity
    }
}
