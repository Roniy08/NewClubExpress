//
//  DirectoryEntryLabels.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntryLabels {
    let parent1: String?
    let parent2: String?
    let studentSingular: String?
    let studentPlural: String?
    
    init(parent1: String?, parent2: String?, studentSingular: String?, studentPlural: String?) {
        self.parent1 = parent1
        self.parent2 = parent2
        self.studentSingular = studentSingular
        self.studentPlural = studentPlural
    }
}
