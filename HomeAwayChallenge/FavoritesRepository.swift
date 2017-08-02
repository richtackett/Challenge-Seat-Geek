//
//  FavoritesRepository.swift
//  HomeAwayChallenge
//
//  Created by rtackett on 8/1/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import Foundation
import CoreData

class FavoritesRepository {
    fileprivate let managedContext = CoreDataStack.shared.managedContext
    fileprivate let favoritesFetch: NSFetchRequest<Favorites> = Favorites.fetchRequest()
    
    func isEventFavorite(eventID: Int64) -> Bool {
        favoritesFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Favorites.eventID), NSNumber(value:eventID))
        
        do {
            let results = try CoreDataStack.shared.managedContext.fetch(favoritesFetch)
            if results.count > 0 {
                return true
            } else {
                return false
            }
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
            return false
        }
    }
    
    func markAsFavorite(eventID: Int64) {
        favoritesFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Favorites.eventID), NSNumber(value:eventID))
        
        do {
            let results = try CoreDataStack.shared.managedContext.fetch(favoritesFetch)
            if results.count > 0 {
                if let favorite = results.first {
                    CoreDataStack.shared.managedContext.delete(favorite)
                }
                
            } else {
                let favorite = Favorites(context: CoreDataStack.shared.managedContext)
                favorite.eventID = eventID
            }
            
            try CoreDataStack.shared.managedContext.save()
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
}
