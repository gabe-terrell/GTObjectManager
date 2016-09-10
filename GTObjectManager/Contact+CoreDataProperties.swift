//
//  Contact+CoreDataProperties.swift
//  GTObjectManager
//
//  Created by Gabe Terrell on 6/14/16.
//  Copyright © 2016 Gabe Terrell. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Contact {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?

}
