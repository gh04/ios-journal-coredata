//
//  Entry+Convenience.swift
//  Journal
//
//  Created by Gerardo Hernandez on 2/12/20.
//  Copyright © 2020 Gerardo Hernandez. All rights reserved.
//

import Foundation
import CoreData



extension Entry {
    
    var entryRepresentation: EntryRepresentation? {
        guard let mood = mood else {
                return nil
        }
        return EntryRepresentation(title: title,
                                   bodyText: bodyText,
                                   timestamp: timestamp,
                                   identifier: identifier,
                                   mood: mood)
    }
    
    @discardableResult
    convenience init(title: String,
                     bodyText: String,
                     timestamp: Date = Date(),
                     identifier: String? = UUID().uuidString,
                     mood: String,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.identifier = identifier
        self.mood = mood 
    }
    
    @discardableResult
    convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let title = entryRepresentation.title,
            let bodyText = entryRepresentation.bodyText,
            let timestamp = entryRepresentation.timestamp,
            let identifierString = entryRepresentation.identifier else { return nil
        }
        self.init(title: title,
                  bodyText: bodyText,
                  timestamp: timestamp,
                  identifier: identifierString,
                  mood: entryRepresentation.mood,
                  context: context)
    }
}
