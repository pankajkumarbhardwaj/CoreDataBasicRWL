//
//  Pet+CoreDataProperties.swift
//  PetUsingCoreData
//
//  Created by Pankaj Kumar on 23/02/20.
//  Copyright © 2020 Pankaj Kumar. All rights reserved.
//
//

import Foundation
import CoreData


extension Pet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pet> {
        return NSFetchRequest<Pet>(entityName: "Pet")
    }

    @NSManaged public var name: String
    @NSManaged public var kind: String
    @NSManaged public var picture: Data?
    @NSManaged public var dob: Date?
    @NSManaged public var owner: Friend

}
