//
//  Arrey+Extension.swift
//  PetUsingCoreData
//
//  Created by Pankaj Kumar on 21/01/20.
//  Copyright © 2020 Pankaj Kumar. All rights reserved.
//

import Foundation

extension Array {
    func random() -> Element? {
        if self.isEmpty {
            return nil
        }
        let index = self.count.random()
        return self[index]
    }
}
