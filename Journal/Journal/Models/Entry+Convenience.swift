//
//  Entry+Convenience.swift
//  Journal
//
//  Created by Gerardo Hernandez on 2/12/20.
//  Copyright © 2020 Gerardo Hernandez. All rights reserved.
//

import Foundation
import CoreData

enum Mood: String {
    case 🙁
    case 😐
    case 🙂
    
    static var allMooods: [Mood] {
        return [.🙁, .😐, .🙂]
    }
}

extension Entry {
    @discardableResult
    convenience init(title: String, bodyText: String, timestamp: Date = Date(), identifier: String? = UUID().uuidString, mood: Mood = .😐, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.identifier = identifier
        self.mood = mood.rawValue
    }
}
