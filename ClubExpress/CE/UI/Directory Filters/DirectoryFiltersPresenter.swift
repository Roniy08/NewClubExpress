//
//  DirectoryFiltersPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol DirectoryFiltersView: class {
    func closePopup()
    func setFilters(filters: Array<DirectoryFilter>)
    func setAppliedFilters(appliedFilters: Array<DirectoryAppliedFilter>)
    func reloadTableView()
    func reloadTableViewRow(index: Int)
    func toggleLoadingIndicator(loading: Bool)
    func showErrorLoadingFiltersPopup(message: String)
    func toggleClearAllFiltersBtn(show: Bool)
    func showCloseConfirmPopup()
    func dismissPickerViews()
    func sendFiltersDidChange()
    func prepareFilters()
}

class DirectoryFiltersPresenter {
    weak var view: DirectoryFiltersView?
    fileprivate var interactor: DirectoryFiltersInteractor
    fileprivate var filters = Array<DirectoryFilter>()
    fileprivate var appliedFilters = Array<DirectoryAppliedFilter>()
    fileprivate var filtersChanged = false
    
    init(interactor: DirectoryFiltersInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        getFilters()
        view?.toggleClearAllFiltersBtn(show: false)
    }
    
    fileprivate func getFilters() {
        view?.toggleLoadingIndicator(loading: true)
        
        interactor.getDirectoryFilters().done { [weak self] (filters) in
            guard let weakSelf = self else { return }
            weakSelf.filters = filters
            weakSelf.view?.setFilters(filters: weakSelf.filters)
            weakSelf.view?.prepareFilters()
            weakSelf.view?.reloadTableView()
            
            weakSelf.getAppliedFilters()
            
            }.catch { [weak self] (error) in
                guard let weakSelf = self else { return }
                let errorMessage = "There was an error loading the directory filters. Please try again."
                weakSelf.view?.showErrorLoadingFiltersPopup(message: errorMessage)
            }.finally { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.view?.toggleLoadingIndicator(loading: false)
        }
    }
    
    fileprivate func getAppliedFilters() {
        self.appliedFilters = interactor.getAppliedFilters()
        view?.setAppliedFilters(appliedFilters: self.appliedFilters)
        view?.reloadTableView()
        configureRemoveAllFiltersBtn()
    }
    
    func closeBarBtnPressed() {
        if filtersChanged {
            if interactor.hasCloseFiltersConfirmPopupShown() {
                closePopupConfirmed()
            } else {
                view?.showCloseConfirmPopup()
                interactor.setShownCloseFiltersConfirmPopup()
            }
        } else {
            view?.closePopup()
        }
    }
    
    func applyBtnPressed() {
        interactor.saveAppliedFilters(appliedFilters: self.appliedFilters)
        view?.sendFiltersDidChange()
        view?.closePopup()
    }
    
    func didChangeFilterOption(filter: DirectoryFilter, option: DirectoryFilterOption?) {
        if let option = option {
            //Add/Update
            let existingAppliedFilterIndex = self.appliedFilters.firstIndex { (appliedFilter) -> Bool in
                return appliedFilter.filter?.name == filter.name
            }
            if let existingAppliedFilterIndex = existingAppliedFilterIndex {
                //Update
                self.appliedFilters[existingAppliedFilterIndex].selectedOption = option
            } else {
                //Add
                let newAppliedFilter = DirectoryAppliedFilter(filter: filter, selectedOption: option)
                self.appliedFilters.append(newAppliedFilter)
            }
        } else {
            //Option is nil so remove if exists
            let updatedAppliedFilters = self.appliedFilters.filter { (directoryAppliedFilter) -> Bool in
                return directoryAppliedFilter.filter?.name != filter.name
            }
            self.appliedFilters = updatedAppliedFilters
        }
        
        view?.setAppliedFilters(appliedFilters: self.appliedFilters)
        configureRemoveAllFiltersBtn()
        
        //Reload cell to update
        let row = filters.firstIndex { (filterItem) -> Bool in
            return filterItem.name == filter.name
        }
        if let row = row {
            view?.reloadTableViewRow(index: row)
        }
        
        if filtersChanged == false {
            filtersChanged = true
        }
    }
    
    func clearAllFiltersBtnPressed() {
        view?.dismissPickerViews()
        self.appliedFilters = []
        view?.setAppliedFilters(appliedFilters: self.appliedFilters)
        view?.reloadTableView()
        configureRemoveAllFiltersBtn()
    }
    
    func configureRemoveAllFiltersBtn() {
        if self.appliedFilters.count > 0 {
            view?.toggleClearAllFiltersBtn(show: true)
        } else {
            view?.toggleClearAllFiltersBtn(show: false)
        }
    }
    
    func closePopupConfirmed() {
        view?.closePopup()
    }
    
    func viewTapGesturePressed() {
        view?.dismissPickerViews()
    }
}
