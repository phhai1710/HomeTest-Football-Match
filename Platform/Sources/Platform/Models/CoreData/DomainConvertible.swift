//
//  DomainConvertible.swift
//  
//
//  Created by Hai Pham on 27/02/2023.
//

import Foundation
import CoreData

protocol DomainConvertible {
    associatedtype DomainType
    
    func asDomain() -> DomainType?
}

protocol CoreDataRepresentable {
    associatedtype CoreDataType: DomainConvertible
    
    func asCoreData(context: NSManagedObjectContext) -> CoreDataType
}
