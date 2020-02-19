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
   
    
    init() {
        fetchEntriesFromServer()
    }
    //MARK: - Properties
    
//    lazy private (set) var entries: [Entry] = {
//        loadFromPersistentStore()
//    }()
    
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
    
    func fetchEntriesFromServer(completion: @escaping completionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
         
            guard error == nil else {
                print("Error fetching tasks: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            
            do {
                let entryRepresentations = Array(try jsonDecoder.decode([String : EntryRepresentation].self, from: data).values)
                try self.updateEntries(with: entryRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding task representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
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
    
    func updateEntries(with representations: [EntryRepresentation]) throws {
        let entriesWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = representations.compactMap { $0.identifier }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, entriesWithID))
        var entriesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN $@", identifiersToFetch)
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            let existingEntries = try context.fetch(fetchRequest)
            
            for entry in existingEntries {
                guard let id = entry.identifier,
                    let representation = representationsByID[id] else { continue }
                self.update(entry: entry, with: representation)
                entriesToCreate.removeValue(forKey: id)
            }
            for representation in entriesToCreate.values {
                Entry(entryRepresentation: representation, context: context)
            }
        } catch {
            print("Error fetching task for UUIDs: \(error)")
        }
        saveToPersistentStore()
    }
    
    private func update(entry: Entry, with representation: EntryRepresentation) {
        entry.title = representation.title
        entry.bodyText = representation.bodyText
        entry.timestamp = representation.timestamp
        entry.identifier = representation.identifier
        entry.mood = representation.mood
    }
    
    // MARK: - Persistence
  private func saveToPersistentStore() {
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
