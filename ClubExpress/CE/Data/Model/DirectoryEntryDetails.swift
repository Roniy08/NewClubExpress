//
//  DirectoryEntryDetails.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntryDetails {
    let parent1: DirectoryEntryPerson?
    let parent2: DirectoryEntryPerson?
    let students: Array<DirectoryEntryPerson>
    let labels: DirectoryEntryLabels?
    var isFavourite: Bool?
    let ads : Array<NativeAd>?
    
    init(parent1: DirectoryEntryPerson?, parent2: DirectoryEntryPerson?, students: Array<DirectoryEntryPerson>, labels: DirectoryEntryLabels?, isFavourite: Bool?, ads: Array<NativeAd>?) {
        self.parent1 = parent1
        self.parent2 = parent2
        self.students = students
        self.labels = labels
        self.isFavourite = isFavourite
        self.ads = ads
    }
}
