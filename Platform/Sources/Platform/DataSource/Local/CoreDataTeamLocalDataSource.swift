//
//  CoreDataTeamLocalDataSource.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

import Domain
import CoreData
import Combine

/// Implementation of TeamLocalDataSource using CoreData
final class CoreDataTeamLocalDataSource: BaseCoreDataDataSource, TeamLocalDataSource {
    /**
     Fetches all football teams from CoreData

     - Returns: All previous and upcoming matches
     */
    func getFootballTeams() -> AnyPublisher<[Domain.FootballTeam], Error> {
        let request: NSFetchRequest<FootballTeamEntity> = FootballTeamEntity.fetchRequest()
        do {
            let entities = try service.context.fetch(request).compactMap { $0.asDomain() }
            return Result.Publisher(.success(entities)).eraseToAnyPublisher()
        } catch let error {
            return Result.Publisher(.failure(error)).eraseToAnyPublisher()
        }
    }
    
    /// Save football teams into Core Data
    func saveFootballTeams(teams: [FootballTeam]) {
        service.context.performAndWait {
            teams.forEach { team in
                _ = team.asCoreData(context: service.context)
            }

            service.saveContext()
        }
    }
    
    /// Delete all football teams in Core Data
    func deleteFootballTeams() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FootballTeamEntity")
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
