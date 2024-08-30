//
//  DirectoryPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol DirectoryView: class {
    func setEntries(entries: Array<DirectoryEntry>)
    func showAds(ads: Array<NativeAd>)
    func toggleLoadingIndicator(loading: Bool)
    func endRefreshControlAnimating()
    func showErrorLoadingDirectoryPopup(message: String)
    func dismissSearchBar()
    func showEmptyPlaceholderView(title: String, message: String)
    func removeEmptyPlaceholderView()
    func showFiltersModal()
    func showAppliedFiltersView(appliedFilters: Array<DirectoryAppliedFilter>)
    func hideAppliedFiltersView()
    func toggleFilterBtnIndicator(show: Bool)
    func toggleFavouritesFilterBtn(filtered: Bool)
    func pushToDirectoryDetail(id: String, name: String)
    func sendEventToChangePageToWebContent(url: String)
}

class DirectoryPresenter {
    weak var view: DirectoryView?
    fileprivate var interactor: DirectoryInteractor
    fileprivate var allEntries = Array<DirectoryEntry>()
    fileprivate var shownEntries = Array<DirectoryEntry>()
    fileprivate var searchTerm: String?
    fileprivate var filterToFavourites = false
    
    init(interactor: DirectoryInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        interactor.clearAppliedFilters()
        loadContent()
    }
    
    func viewWillDisappear() {
        view?.dismissSearchBar()
    }
    
    func loadContent() {
        resetEntries()
        getDirectoryEntries()
        getAppliedFilters()
    }
    
    func getDirectoryEntries(refreshing: Bool = false) {
        if refreshing == false {
            view?.toggleLoadingIndicator(loading: true)
        }
        
        interactor.getDirectoryEntries().done { [weak self] (response) in
            guard let weakSelf = self else { return }
            if(response.showAds != nil || response.showAds.count < 1){
                self!.setAds(ads: response.showAds)
            }
            if response.entries.count > 0 {
                weakSelf.allEntries = weakSelf.sortEntries(entries: response.entries)
                weakSelf.showEntries()
                print(weakSelf.allEntries[0].lastName2)
            }
            else{
                let title = "No results found"
                let errorMessage = "There were no results found. Please try again."
                weakSelf.view?.showEmptyPlaceholderView(title: title, message: errorMessage)
            }
           
        }.catch { [weak self] (error) in
            guard let weakSelf = self else { return }
            switch error {
            case APIError.errorReturned(let error):
                if let errorCode = error.errorCode, let errorUrl = error.errorUrl, errorCode == "NO-DIRECTORY-ACCESS", errorUrl.count > 0 {
                    let fullUrl = weakSelf.interactor.getBaseUrl() + errorUrl
                    weakSelf.view?.sendEventToChangePageToWebContent(url: fullUrl)
                } else if let errorMessage = error.errorMessage {
                    weakSelf.view?.showErrorLoadingDirectoryPopup(message: errorMessage)
                } else {
                    let title = "Error loading the directory"
                    let errorMessage = "There was an error loading the directory. Please try again."
                    weakSelf.view?.showEmptyPlaceholderView(title: title, message: errorMessage)
    
                }
            default:
                let title = "Error loading the directory"
                let errorMessage = "There was an error loading the directory. Please try again."
                weakSelf.view?.showEmptyPlaceholderView(title: title, message: errorMessage)
//                weakSelf.view?.showErrorLoadingDirectoryPopup(message: errorMessage)
            }
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.toggleLoadingIndicator(loading: false)
            weakSelf.view?.endRefreshControlAnimating()
        }
    }
    
    fileprivate func getAppliedFilters() {
        let appliedFilters = interactor.getAppliedFilters()
        if appliedFilters.count > 0 {
            view?.showAppliedFiltersView(appliedFilters: appliedFilters)
            view?.toggleFilterBtnIndicator(show: true)
        } else {
            view?.hideAppliedFiltersView()
            view?.toggleFilterBtnIndicator(show: false)
        }
    }
    
    func pulledToRefresh() {
        getDirectoryEntries(refreshing: true)
    }
    
    func setAds(ads: Array<NativeAd>) {
        view?.showAds(ads: ads)
    }
    
    //...... any apostrophe symbols are replaces with ' symbol during search on 9th apr 2024

       func searchBtnPressed(searchTerm: String) {
           var convertedString = searchTerm
               if searchTerm.contains("‘") || searchTerm.contains("’") || searchTerm.contains("‘")
               {
                   convertedString = searchTerm
                          .replacingOccurrences(of: "‘", with: "'")
                          .replacingOccurrences(of: "’", with: "'")
                          .replacingOccurrences(of: "‘", with: "'")
                   setSearchTerm(searchTerm: convertedString)
                   showEntries()
               }
               else
               {
                   setSearchTerm(searchTerm: searchTerm)
                   showEntries()
               }
   //        showEntries()
           setSearchTerm(searchTerm: searchTerm)
           print("searched text: ",searchTerm)
           showEntries()

           view?.dismissSearchBar()
       }
    
    fileprivate func showEntries() {
        self.shownEntries = entriesToShow()
        view?.setEntries(entries: self.shownEntries)
        if self.shownEntries.count == 0 {
            let title = "No Directory Entries"
            var message = "There are no directory entries matching your search term or applied filters"
            if filterToFavourites {
                message = "There are no favorited directory entries matching your search term or applied filters"
            }
            view?.showEmptyPlaceholderView(title: title, message: message)
        } else {
            view?.removeEmptyPlaceholderView()
        }
    }
    
    fileprivate func entriesToShow() -> Array<DirectoryEntry> {
        if filterToFavourites {
            if searchTerm != nil {
                return searchFavouritedEntries()
            } else {
                return showAllFavouritedEntries()
            }
        } else {
            if searchTerm != nil {
                return searchAllEntries()
            } else {
                return self.allEntries
            }
        }
    }
    
    fileprivate func setSearchTerm(searchTerm: String) {
        if searchTerm == "" {
            self.searchTerm = nil
        } else {
            self.searchTerm = searchTerm
        }
    }
    
    //...... any apostrophe symbols are replaces with ' symbol during search on 9th apr 2024

       func searchTermDidChange(searchTerm: String) {
           var convertedString = searchTerm
               if searchTerm.contains("‘") || searchTerm.contains("’") || searchTerm.contains("‘")
               {
                   convertedString = searchTerm
                          .replacingOccurrences(of: "‘", with: "'")
                          .replacingOccurrences(of: "’", with: "'")
                          .replacingOccurrences(of: "‘", with: "'")
                   setSearchTerm(searchTerm: convertedString)
                   showEntries()
               }
               else
               {
                   setSearchTerm(searchTerm: searchTerm)
                   showEntries()
               }
   //        setSearchTerm(searchTerm: searchTerm)
   //        showEntries()
           setSearchTerm(searchTerm: searchTerm)
           showEntries()
       }
    
    func cancelSearchBtnPressed() {
        searchTerm = nil
        view?.dismissSearchBar()
        
        showEntries()
    }
    
    fileprivate func searchAllEntries() -> Array<DirectoryEntry> {
        let searchedEntries = searchEntries(entries: self.allEntries)
        return searchedEntries
    }
    
    fileprivate func searchFavouritedEntries() -> Array<DirectoryEntry> {
        let favouritedEntries = getFavouritedEntries()
        let searchedEntries = searchEntries(entries: favouritedEntries)
        return searchedEntries
    }
    
    fileprivate func searchEntries(entries: Array<DirectoryEntry>) -> Array<DirectoryEntry> {
        guard let searchTerm = self.searchTerm else { return [] }
        let lowercasedSearchTerm = searchTerm.lowercased()
        
        let searchedEntries = entries.filter({ (entry) -> Bool in
            //Check parent names
            let parentNamesString = createParentNamesString(entry: entry).lowercased()
            if parentNamesString.contains(lowercasedSearchTerm) {
                return true
            } else {
                //Check children names
                guard let students = entry.students else { return false }
                let studentNamesString = createStudentNamesString(students: students).lowercased()
                if studentNamesString.contains(lowercasedSearchTerm) {
                    return true
                } else {
                    return false
                }
            }
        })
        
        return sortEntries(entries: searchedEntries)
    }
    
    fileprivate func showAllFavouritedEntries() -> Array<DirectoryEntry> {
        let favouritedEntries = getFavouritedEntries()
        return favouritedEntries
    }
    
    fileprivate func getFavouritedEntries() -> Array<DirectoryEntry> {
        return self.allEntries.filter({ (entry) -> Bool in
            return (entry.isFavourite ?? false)
        })
    }
    
    fileprivate func sortEntries(entries: Array<DirectoryEntry>) -> Array<DirectoryEntry> {
        return entries.sorted(by: { (entryA, entryB) -> Bool in
            let entryASortKey = entryA.sortKey ?? 0
            let entryBSortKey = entryB.sortKey ?? 0
            
            return entryASortKey < entryBSortKey
        })
    }
    
    fileprivate func createParentNamesString(entry: DirectoryEntry) -> String {
        var firstParentNamesArray = Array<String>()
        var secondParentNamesArray = Array<String>()
        
        if let firstName = entry.firstName {
            firstParentNamesArray.append(firstName)
        }
        if let lastName = entry.lastName {
            firstParentNamesArray.append(lastName)
        }
        if let firstName2 = entry.firstName2 {
            secondParentNamesArray.append(firstName2)
        }
        if let lastName2 = entry.lastName2 {
            secondParentNamesArray.append(lastName2)
        }
        
        let firstParent = firstParentNamesArray.joined(separator: " ")
        let secondParent = secondParentNamesArray.joined(separator: " ")
        
        var parentNamesArray = Array<String>()
        if firstParent.count > 0 {
            parentNamesArray.append(firstParent)
        }
        if secondParent.count > 0 {
            parentNamesArray.append(secondParent)
        }
        
        return parentNamesArray.joined(separator: " & ")
    }
    
    fileprivate func createStudentNamesString(students: Array<DirectoryStudent>) -> String {
        var studentNamesArray = Array<String>()
        students.forEach({ (student) in
            if let studentFirstName = student.firstName {
                studentNamesArray.append(studentFirstName)
            }
            if let studentLastName = student.lastName {
                studentNamesArray.append(studentLastName)
            }
        })
        return studentNamesArray.joined(separator: " ")
    }
    
    func filtersBarBtnPressed() {
        view?.showFiltersModal()
    }
    
    func clearFiltersBtnPressed() {
        interactor.clearAppliedFilters()
        loadContent()
    }
    
    fileprivate func resetEntries() {
        self.allEntries = []
        self.shownEntries = []
        view?.setEntries(entries: self.allEntries)
        view?.removeEmptyPlaceholderView()
    }
    
    func didSelectRow(row: Int) {
        if row < shownEntries.count {
            let entry = shownEntries[row]
            
            guard let entryID = entry.id else { return }
            let nameString = createParentNamesString(entry: entry)
            view?.pushToDirectoryDetail(id: entryID, name: nameString)
        }
    }
    
    func openAppliedFiltersBtnPressed() {
        view?.showFiltersModal()
    }
    
    func filtersDidChange() {
        loadContent()
    }
    
    func directoryDidChangeFavourite() {
        loadContent()
    }
    
    func favouriteFilterBarBtnPressed() {
        filterToFavourites = true
        view?.toggleFavouritesFilterBtn(filtered: true)
        showEntries()
    }
    
    func removeFavouriteFilterBarBtnPressed() {
        filterToFavourites = false
        view?.toggleFavouritesFilterBtn(filtered: false)
        showEntries()
    }
}
