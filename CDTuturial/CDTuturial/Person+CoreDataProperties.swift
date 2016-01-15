//
//  Person+CoreDataProperties.swift
//  CDTuturial
//
//  Created by shinisaru on 15/01/16.
//  Copyright © 2016 Avast. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?

}
