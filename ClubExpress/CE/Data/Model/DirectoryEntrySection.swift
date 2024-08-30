//
//  DirectoryEntrySection.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntrySection {
    let headerLabel: String
    let people: Array<DirectoryEntryPerson>?
    
    init(headerLabel: String, people: Array<DirectoryEntryPerson>) {
        self.headerLabel = headerLabel
        self.people = people
    }
}
