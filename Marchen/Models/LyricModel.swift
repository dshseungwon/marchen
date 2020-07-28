//
//  LyricModel.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/27.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import Foundation
import RealmSwift

class LyricModel: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var dateOfCreation : Date?
    @objc dynamic var dateOfRecentEdit : Date?
    
    let lines = List<String>()
    
}
