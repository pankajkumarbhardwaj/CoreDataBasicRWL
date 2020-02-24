//
//  Friend+CoreDataProperties.swift
//  PetUsingCoreData
//
//  Created by Pankaj Kumar on 24/02/20.
//  Copyright © 2020 Pankaj Kumar. All rights reserved.
//
//

import Foundation
import CoreData


extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var address: String?
    @NSManaged public var dob: Date?
    @NSManaged public var eyeColour: NSObject?
    @NSManaged public var name: String
    @NSManaged public var photo: Data?
    @NSManaged public var pets: NSSet

}

// MARK: Generated accessors for pets
extension Friend {

    @objc(addPetsObject:)
    @NSManaged public func addToPets(_ value: Pet)

    @objc(removePetsObject:)
    @NSManaged public func removeFromPets(_ value: Pet)

    @objc(addPets:)
    @NSManaged public func addToPets(_ values: NSSet)

    @objc(removePets:)
    @NSManaged public func removeFromPets(_ values: NSSet)

}
