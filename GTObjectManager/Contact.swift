//
//  Contact.swift
//  GTObjectManager
//
//  Created by Gabe Terrell on 6/14/16.
//  Copyright © 2016 Gabe Terrell. All rights reserved.
//

import Foundation
import CoreData

extension Contact: GTManagedObjectIdentifiable {
    class func managedObjectEntityName() -> String {
        return "Contact"
    }
}

class Contact: NSManagedObject {
    class func createContactWithName(first first: String?, last: String?) -> Contact {
        let contact = GTObjectManager.createObjectOfType(Contact)!
        contact.firstName = first
        contact.lastName = last
        
        GTObjectManager.saveAllChanges()
        
        return contact
    }
    
    class func fetchAllContacts(withSearchTerm searchTerm: String? = nil) -> [Contact] {
        let sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        let compoundPredicate: NSPredicate?
        if let term = searchTerm {
            let firstNamePredicate = NSPredicate(format: "firstName CONTAINS[cd] %@", argumentArray: [term])
            let lastNamePredicate = NSPredicate(format: "lastName CONTAINS[cd] %@", argumentArray: [term])
            compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [firstNamePredicate, lastNamePredicate])
        }
        else {
            compoundPredicate = nil
        }
        
        return GTObjectManager.fetchAllObjectsOfType(Contact.self, predicate: compoundPredicate, sortDescriptors: sortDescriptors)!
    }
}