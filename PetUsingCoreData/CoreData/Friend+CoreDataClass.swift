//
//  Friend+CoreDataClass.swift
//  PetUsingCoreData
//
//  Created by Pankaj Kumar on 15/11/19.
//  Copyright © 2019 Pankaj Kumar. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit


public class Friend: NSManagedObject {

    var age:Int {
        if let dob = dob as? Date {
            return Calendar.current.dateComponents([.year], from: dob, to: Date()).year!
        }
        return 0
    }
    
    var eyeColourString:String {
        guard let colour = eyeColour as? UIColor else {
            return "No Colour"
        }
        switch colour {
        case UIColor.black:
            return "Black"
        case UIColor.blue:
            return "Blue"
        case UIColor.brown:
            return "Brown"
        case UIColor.green:
            return "Green"
        case UIColor.gray:
            return "gray"
        default:
            return "Unknown"
        
        }
    }
}
