//
//  Note.swift
//  NotesApp
//
//  Created by Danny Vo on 2020-06-21.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit

class Note: NSObject, Codable {
    var body: String
    
    init(body: String) {
        self.body = body
    }
}
