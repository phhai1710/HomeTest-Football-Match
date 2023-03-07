//
//  CoreDataServiceImpl.swift
//  
//
//  Created by Hai Pham on 01/03/2023.
//

import CoreData

/// The service class for managing Core Data stack with initial implementation
final class CoreDataService {
    static let shared = CoreDataService()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        // Load the `NSManagedObjectModel` from the app's bundle.
        guard let modelURL = Bundle.module.url(forResource:"FootballMatches", withExtension: "momd"),
                let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Can not load CoreData model")
        }
        let container = NSPersistentContainer(name:"FootballMatches", managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    /**
     Saves the changes in the `context` to the persistent store.
     */
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
