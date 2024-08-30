//
//  DirectoryEntryPerson.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

enum directoryEntryPersonType {
    case parent
    case student
}

class DirectoryEntryPerson {
    var fields: Array<DirectoryEntryField>
    let type: directoryEntryPersonType
    
    init(fields: Array<DirectoryEntryField>, type: directoryEntryPersonType) {
        self.fields = fields
        self.type = type
    }
}
