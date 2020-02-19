//
//  EntryRepresentation.swift
//  Journal
//
//  Created by Gerardo Hernandez on 2/18/20.
//  Copyright © 2020 Gerardo Hernandez. All rights reserved.
//

import Foundation
 
struct EntryRepresentation: Codable {
    var title: String?
    var bodyText: String?
    var timestamp: Date?
    var identifier: String?
    var mood: String
    
}
