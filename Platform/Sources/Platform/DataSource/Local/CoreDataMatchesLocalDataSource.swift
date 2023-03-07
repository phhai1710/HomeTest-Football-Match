//
//  CoreDataMatchesLocalDataSource.swift
//  
//
//  Created by Hai Pham on 25/02/2023.
//

import Domain
import CoreData
import Combine

/// Implementation of MatchesLocalDataSource using CoreData
final class CoreDataMatchesLocalDataSource: BaseCoreDataDataSource, MatchesLocalDataSource {

    /**
     Fetches all football matches from CoreData

     - Returns: Previous and upcoming matches
     */
    func getFootballMatches() -> AnyPublisher<(previous: [FootballMatch], incoming: [FootballMatch]), Error> {
        let request: NSFetchRequest<FootballMatchEntity> = FootballMatchEntity.fetchRequest()
        do {
            let entities = try service.context.fetch(request)
            var previous = [FootballMatch]()
            var upcoming = [FootballMatch]()
            entities.forEach { entity in
                if let domain = entity.asDomain() {
                    if entity.isUpcoming {
                        upcoming.append(domain)
                    } else {
                        previous.append(domain)
                    }
                }
            }
            return Result.Publisher(.success((previous, upcoming))).eraseToAnyPublisher()
        } catch let error {
            return Result.Publisher(.failure(error)).eraseToAnyPublisher()
        }
    }
    
    /// Save football matches into Core Data
    func saveFootballMatches(previous: [FootballMatch], incoming: [FootballMatch]) {
        service.context.performAndWait {
            previous.forEach { match in
                let entity = match.asCoreData(context: service.context)
                entity.isUpcoming = false
            }
            incoming.forEach { match in
                let entity = match.asCoreData(context: service.context)
                entity.isUpcoming = true
            }

            service.saveContext()
        }
    }
    
    /// Delete all football matches in Core Data
    func deleteFootballMatches() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FootballMatchEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do
        {
            try service.context.execute(deleteRequest)
            try service.context.save()
        }
        catch
        {
            print ("Can not delete")
        }
    }
}
