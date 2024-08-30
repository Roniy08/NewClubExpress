//
//  DirectoryFiltersLocalSource.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol DirectoryFiltersLocalSource {
    func getAppliedFilters() -> Array<DirectoryAppliedFilter>
    func saveAppliedFilters(appliedFilters: Array<DirectoryAppliedFilter>)
    func clearAllAppliedFilters()
}

class DirectoryFiltersLocalSourceImpl: DirectoryFiltersLocalSource {
    var appliedFilters = Array<DirectoryAppliedFilter>()
    
    func getAppliedFilters() -> Array<DirectoryAppliedFilter> {
        return appliedFilters
    }
    
    func saveAppliedFilters(appliedFilters: Array<DirectoryAppliedFilter>) {
        self.appliedFilters = appliedFilters
    }
    
    func clearAllAppliedFilters() {
        self.appliedFilters = []
    }
}
