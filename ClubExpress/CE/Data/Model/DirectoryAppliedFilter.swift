//
//  DirectoryAppliedFilter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryAppliedFilter {
    var filter: DirectoryFilter?
    var selectedOption: DirectoryFilterOption?
    
    init(filter: DirectoryFilter?, selectedOption: DirectoryFilterOption) {
        self.filter = filter
        self.selectedOption = selectedOption
    }
}
