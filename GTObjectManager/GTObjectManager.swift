//
//  GTObjectManager.swift
//  GTObjectManager
//
//  Created by Gabe Terrell on 2/20/16.
//  Copyright © 2016 Gabe Terrell. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: Setup Steps for GTObjectManager

// To make a project compatible with GTObjectManager, the AppDelegate must conform to
// the GTCoreDataIdentifiable protocol so GTObjectManager can access the app's managedObjectContext.
// If the project was setup initially with core data, the managedObjectContext property should
// already exist from the initial creation of the project. In this case, simply add GTCoreDataIdentifiable
// as a protocol that AppDelegate conforms to.
protocol GTCoreDataIdentifiable {
    var managedObjectContext: NSManagedObjectContext { get }
}

// To make an NSManagedObject subclass compatible with GTObjectManager,
// it must conform to the GTManagedObjectIdentifiable protocol
// The managedObjectEntityName() function simply returns the entity name of the NSManagedObject
protocol GTManagedObjectIdentifiable {
    static func managedObjectEntityName() -> String
}

// MARK: - GTObjectManager API
class GTObjectManager {
    /**
     Returns a new instance of the NSManagedObject type specified
     */
    static func createObjectOfType <T where T: NSManagedObject, T: GTManagedObjectIdentifiable> (type: T.Type) -> T? {
        if let managedObjectContext = GTObjectManager.fetchManagedObjectContext() {
            let entityName = type.managedObjectEntityName()
            if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext) {
                let managedObject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
                return managedObject as? T
            }
        }
        return nil
    }
    
    /**
     Returns the results of an NSFetchRequest for the NSManagedObject type specified
     */
    static func fetchAllObjectsOfType <T where T: NSManagedObject, T: GTManagedObjectIdentifiable>
        (type: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T]? {

        guard let managedObjectContext = GTObjectManager.fetchManagedObjectContext() else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest(entityName: type.managedObjectEntityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        return (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [T]
    }
    
    /**
     Returns the number of results of an NSFetchRequest for the NSManagedObject type specified
     */
    static func countAllObjectsOfType <T where T: NSManagedObject, T: GTManagedObjectIdentifiable>
        (type: T.Type, predicate: NSPredicate? = nil) -> Int {
        if let managedObjectContext = GTObjectManager.fetchManagedObjectContext() {
            let fetchRequest = NSFetchRequest(entityName: type.managedObjectEntityName())
            fetchRequest.predicate = predicate
            fetchRequest.includesSubentities = false
            var error: NSError? = nil
            let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
            if error == nil {
                return count
            }
        }
        return -1
    }
    
    /**
     Deletes the passed NSManagedObject from the singleton app's managedObjectContext
     */
    static func deleteObject (object: NSManagedObject) -> Bool {
        return GTObjectManager.deleteObjects([object])
    }
    
    /**
     Deletes the passed NSManagedObjects from the singleton app's managedObjectContext
     */
    static func deleteObjects (objects: [NSManagedObject]) -> Bool {
        if let managedObjectContext = GTObjectManager.fetchManagedObjectContext() {
            for object in objects {
                managedObjectContext.deleteObject(object)
            }
            return true
        }
        return false
    }
    
    /**
     Deletes all instances of the NSManagedObject type specified from the singleton app's managedObjectContext
     */
    static func deleteAllObjectsOfType <T where T: NSManagedObject, T: GTManagedObjectIdentifiable> (type: T.Type) -> Bool {
        if let objects = GTObjectManager.fetchAllObjectsOfType(type) {
            return GTObjectManager.deleteObjects(objects)
        }
        return false
    }
    
    /**
     Saves all changes to the singleton app's managedObjectContext
     */
    static func saveAllChanges() -> Bool {
        if let managedObjectContext = GTObjectManager.fetchManagedObjectContext() {
            do {
                try managedObjectContext.save()
                return true
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
                return false
            }
        }
        return false
    }
    
    /**
     Returns the singleton app's managedObjectContext
     */
    private static func fetchManagedObjectContext() -> NSManagedObjectContext? {
        if let appDelegate = UIApplication.sharedApplication().delegate as? GTCoreDataIdentifiable {
            return appDelegate.managedObjectContext
        }
        else {
            return nil
        }
    }
}