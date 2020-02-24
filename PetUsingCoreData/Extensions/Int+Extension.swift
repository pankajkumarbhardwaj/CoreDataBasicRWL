//
//  Int+Extension.swift
//  PetUsingCoreData
//
//  Created by Pankaj Kumar on 21/01/20.
//  Copyright © 2020 Pankaj Kumar. All rights reserved.
//


import Foundation

extension Int {
    func random() -> Int {
        let isNegative = self < 0
        let random = Int(arc4random_uniform(UInt32(abs(self)))) * (isNegative ? -1 : 1)
        return random
    }
}
