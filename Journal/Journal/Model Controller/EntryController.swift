//
//  EntryController.swift
//  Journal
//
//  Created by Gerardo Hernandez on 2/12/20.
//  Copyright © 2020 Gerardo Hernandez. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://journal-day-3-8b31f.firebaseio.com/")!

class EntryController {
    
    typealias completionHandler = (Error?) -> Void
   
    //MARK: - Properties
    
    lazy private (set) var entries: [Entry] = {
        loadFromPersistentStore()
    }()
    
    func put(entry: Entry, completion: @escaping completionHandler = { _ in }) {
        let uuid = entry.identifier ?? UUID().uuidString
        let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = entry.entryRepresentation else {
                //catch these errors gracefully. Ex. in previous modules
                completion(NSError())
                return
            }
            representation.identifier = uuid
            entry.identifier = uuid
            saveToPersistentStore()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding entry \(entry): \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                print("Error PUTing entry to server: \(error!)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    func deleTaskFromServer(_ entry: Entry, completion: @escaping completionHandler = { _ in }) {
        guard let uuid = entry.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            guard error == nil else {
                print("Error deleting task: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Persistence
    func saveToPersistentStore() {
         let moc = CoreDataStack.shared.mainContext
        do {
            //managed object context
            try moc.save()
        } catch {
            moc.reset()
            print("Error saving entry: \(error)")
        }
        
    }
    
    func loadFromPersistentStore() -> [Entry] {
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let moc = CoreDataStack.shared.mainContext
        do {
            return try moc.fetch(fetchRequest)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
        
    }
    
    // MARK: - CRUD
    
    func createEntry(title: String, bodyText: String, mood: String) {
       let entry = Entry(title: title, bodyText: bodyText, mood: mood)
        put(entry: entry)
//        saveToPersistentStore()
    }
    
    func updateEntry(_ entry: Entry, newTitle: String, newbodyText: String, updatedMood: String) {
        let updatedTimestamp = Date()
        let updatedMood = updatedMood
        entry.mood = updatedMood
        entry.title = newTitle
        entry.bodyText = newbodyText
        entry.timestamp = updatedTimestamp
        put(entry: entry)
//        saveToPersistentStore()
        
    
    }
    
    func delete(_ entry: Entry) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(entry)
        deleTaskFromServer(entry)
//        saveToPersistentStore()

        
    }
    
  
}
