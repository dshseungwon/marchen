//
//  SavedSongModel.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/12.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import Foundation
import RealmSwift

class RecordedSongModel: Object {
    @objc dynamic var songName : String = ""
    @objc dynamic var fileName : String = ""
    @objc dynamic var dateOfCreation : Date?
}
