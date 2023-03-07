//
//  BaseCoreDataDataSource.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

/// Base class of CoreData data source. 
class BaseCoreDataDataSource {
    let service: CoreDataService
    init(service: CoreDataService = CoreDataService.shared) {
        self.service = service
    }
}
