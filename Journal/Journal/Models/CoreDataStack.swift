//
//  CoreDataStack.swift
//  Journal
//
//  Created by Gerardo Hernandez on 2/12/20.
//  Copyright © 2020 Gerardo Hernandez. All rights reserved.
//

import Foundation
import CoreData

//Singleton
//4 fours of Core Data Stack
class CoreDataStack {
    
    //MARK: Properties
     private init () {}
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let newContainer = NSPersistentContainer(name: "Entry")
        newContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return newContainer
    } ()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
