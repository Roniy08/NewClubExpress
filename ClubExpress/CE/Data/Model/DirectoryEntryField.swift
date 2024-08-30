//
//  DirectoryEntryField.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

enum directoryEntryFieldType {
    case text
    case phone
    case email
    case address
}

class DirectoryEntryField {
    let name: String?
    let label: String?
    let sortOrder: Int?
    let value: String?
    let type: directoryEntryFieldType?
    
    init(name: String?, label: String?, sortOrder: Int?, value: String?, type: directoryEntryFieldType) {
        self.name = name
        self.label = label
        self.sortOrder = sortOrder
        self.value = value
        self.type = type
    }
}
