//
//  pinExtension.swift
//  VirtualTourist
//
//  Created by Jason on 6/14/18.
//  Copyright © 2018 jlhoopes.com. All rights reserved.
//

import Foundation
import CoreData

extension LocationPin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
