//
//  Helpers.swift
//  AnimatedStyle
//
//  Created by Esteban on 17.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import Foundation

class Helpers {
    
    static func getRandomInRange(from: Int, to: Int) -> Int {
        return Int(arc4random_uniform(UInt32(to)) + UInt32(from))
    }
}
