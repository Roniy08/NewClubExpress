//
//  DirectoryRepository.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class DirectoryRepository {
    fileprivate var directoryFiltersLocalSource: DirectoryFiltersLocalSource
    fileprivate var membershipRemoteSource: MembershipRemoteSource
    
    init(membershipRemoteSource: MembershipRemoteSource, directoryFiltersLocalSource: DirectoryFiltersLocalSource) {
        self.membershipRemoteSource = membershipRemoteSource
        self.directoryFiltersLocalSource = directoryFiltersLocalSource
    }
    
    func getDirectory(sessionToken: String, organisationID: String) -> Promise<DirectoryResponse> {
        return Promise { seal in
            let appliedFilters = getAppliedFilters()
            
            let filters = appliedFilters.compactMap({ (appliedFilter) -> DirectoryRequestFilter? in
                guard let filterName = appliedFilter.filter?.name else { return nil }
                guard let filterValue = appliedFilter.selectedOption?.value else { return nil }
                return DirectoryRequestFilter(name: filterName, value: filterValue)
            })
            
            membershipRemoteSource.getDirectory(sessionToken: sessionToken, organisationID: organisationID, filters: filters).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getDirectoryFilters(sessionToken: String, organisationID: String) -> Promise<DirectoryFiltersResponse> {
        return Promise { seal in
            membershipRemoteSource.getDirectoryFilters(sessionToken: sessionToken, organisationID: organisationID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getAppliedFilters() -> Array<DirectoryAppliedFilter> {
        return directoryFiltersLocalSource.getAppliedFilters()
    }
    
    func saveAppliedFilters(appliedFilters: Array<DirectoryAppliedFilter>) {
        directoryFiltersLocalSource.saveAppliedFilters(appliedFilters: appliedFilters)
    }
    
    func clearAllAppliedFilters() {
        directoryFiltersLocalSource.clearAllAppliedFilters()
    }
    
    func getDirectoryEntry(sessionToken: String, organisationID: String, memberID: String) -> Promise<DirectoryEntryResponse> {
        return Promise { seal in
            membershipRemoteSource.getDirectoryEntry(sessionToken: sessionToken, organisationID: organisationID, memberID: memberID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func toggleDirectoryEntryFavourite(sessionToken: String, organisationID: String, memberID: String, favourited: Bool) -> Promise<BaseResponse> {
        return Promise { seal in
            membershipRemoteSource.toggleDirectoryEntryFavourite(sessionToken: sessionToken, organisationID: organisationID, memberID: memberID, favourited: favourited).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
}
