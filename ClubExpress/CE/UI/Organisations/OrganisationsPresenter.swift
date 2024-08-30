//
//  OrganisationsPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit
import UserNotifications

protocol OrganisationsView: class {
    func setOrganisationsArray(organisations: Array<OrgLogin>)
    func showErrorLoadingOrganisationsPopup(message: String)
    func showErrorLoadingSelectedOrganisationPopup(message: String)
    func toggleLoadingIndicator(loading: Bool)
    func navigateToSelectedOrganisation()
    func toggleFooterView(show: Bool)
    func endRefreshControlAnimating()
    func showOrganisationLoadingView(afterDelay: Bool)
    func removeOrganisationLoadingView()
    func showEmptyPlaceholderView(title: String, message: String)
    func removeEmptyPlaceholderView()
    func setFooterText(footerText: String)
    func showPreNotificationsPermissionPopup()
    func changeToLoginVC()
    func changePageToWebContent(url: String)
    func closeWebView()
    func dismissSearchBar()
}

class OrganisationsPresenter {
    weak var view: OrganisationsView?
    var interactor: OrganisationsInteractor
    fileprivate var organisations = Array<OrgLogin>()
    fileprivate var shownOrganisations = Array<OrgLogin>()
    fileprivate var footerText: String?
    var switchingOrganisation = false
    fileprivate var searchTerm: String?
    init(interactor: OrganisationsInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        //        getOrganisations()
        
//        if switchingOrganisation == false {
//            configureNotifications()
//        }
    }
    
    func getOrganisations(refreshing: Bool = false) {
        //        if refreshing == false {
        //            view?.toggleLoadingIndicator(loading: true)
        //            view?.toggleFooterView(show: false)
        //        }
        //
        //        interactor.getOrganisations().done { [weak self] (organisations) in
        //            guard let weakSelf = self else { return }
        //            weakSelf.organisations = organisations
        //            weakSelf.view?.setOrganisationsArray(organisations: weakSelf.organisations)
        //
        //            if let firstOrganisation = organisations.first {
        //                if let changeOrgMessage = firstOrganisation.changeOrgMessage {
        //                    weakSelf.footerText = changeOrgMessage
        //                    weakSelf.view?.setFooterText(footerText: changeOrgMessage)
        //                }
        //            }
        //
        //            if organisations.count == 0 {
        //                weakSelf.view?.showEmptyPlaceholderView(title: "No Organizations", message: "There was no organizations to show")
        //            } else {
        //                weakSelf.view?.removeEmptyPlaceholderView()
        //            }
        //        }.catch { [weak self] (error) in
        //            guard let weakSelf = self else { return }
        //            switch error {
        //            case APIError.errorReturned(let error):
        //                if let errorCode = error.errorCode, let errorUrl = error.errorUrl, errorCode == "NO_ORGS", errorUrl.count > 0 {
        //                    weakSelf.view?.changePageToWebContent(url: errorUrl)
        //                } else if let errorMessage = error.errorMessage {
        //                    weakSelf.view?.showErrorLoadingOrganisationsPopup(message: errorMessage)
        //                } else {
        //                    let errorMessage = "There was an error loading organizations"
        //                    weakSelf.view?.showErrorLoadingOrganisationsPopup(message: errorMessage)
        //                }
        //            default:
        //                let errorMessage = "There was an error loading organizations"
        //                weakSelf.view?.showErrorLoadingOrganisationsPopup(message: errorMessage)
        //            }
        //        }.finally { [weak self] in
        //            guard let weakSelf = self else { return }
        //            weakSelf.view?.toggleLoadingIndicator(loading: false)
        //            weakSelf.view?.toggleFooterView(show: true)
        //            weakSelf.view?.endRefreshControlAnimating()
        //        }
    }
    
    func pulledToRefresh() {
        //        getOrganisations(refreshing: true)
    }
    
    func didSelectOrganisation(organisation: OrgLogin) {
        guard let organisationID = organisation.org_id else { return }
        print(organisationID)
        print(organisation.member_id)
        MembershipAPIRouter.tempOrgIDStr = String(organisationID)
        MembershipAPIRouter.tempMemberIDStr = String(organisation.member_id)
        self.getExchangetokn()
        print("here home screen after")
//        print(MembershipAPIRouter.homeURLStr!)
//        self.view?.changePageToWebContent(url:MembershipAPIRouter.homeURLStr!)
//        view?.showOrganisationLoadingView(afterDelay: true)
        
//        interactor.getAdditionalOrganisationDetails(organisationID: organisationID).done { [weak self] (success) in
//            guard let weakSelf = self else { return }
//            weakSelf.interactor.setSelectedOrganisation(organisation: organisation)
//            weakSelf.view?.navigateToSelectedOrganisation()
//        }.catch { [weak self] error in
//            guard let weakSelf = self else { return }
//            weakSelf.view?.showErrorLoadingSelectedOrganisationPopup(message: "There was an error loading organization. Please try again.")
//        }.finally { [weak self] in
//            guard let weakSelf = self else { return }
//            weakSelf.view?.removeOrganisationLoadingView()
//        }
    }
    
    func getExchangetokn()
    {
        interactor.createExChangesToken(orgId: MembershipAPIRouter.tempOrgIDStr!, memberId: MembershipAPIRouter.tempMemberIDStr!).done  { [weak self] (_) in
            guard let weakSelf = self else { return }
            if  MembershipAPIRouter.tempSessionTokenStr!.isEmpty == false
            {
                self!.getExchangetosessiontokn()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                weakSelf.view?.changePageToWebContent(url: MembershipAPIRouter.homeURLStr!)
            }
            print("here home screen 2")
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.view?.showErrorLoadingSelectedOrganisationPopup(message: "There was an error loading exchange token. Please try again.")
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.removeOrganisationLoadingView()
        }
    }
    func getExchangetosessiontokn()
    {
        interactor.exchangeToken(tokenstrs: MembershipAPIRouter.tempSessionTokenStr!).done  { [weak self] (_) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self!.configureNotifications()
            }
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.view?.showErrorLoadingSelectedOrganisationPopup(message: "There was an error loading temp token to sessiontoken. Please try again.")
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.removeOrganisationLoadingView()
        }

    }
    func didSelectOrganisationWithId(organisationID: String) {
        
        view?.showOrganisationLoadingView(afterDelay: true)
        
        interactor.getAdditionalOrganisationDetails(organisationID: organisationID).done { [weak self] (success) in
            guard let weakSelf = self else { return }
            var org = weakSelf.interactor.sessionRepository.getSession()?.selectedOrganisation
            if(org != nil && org?.id != nil){
                weakSelf.interactor.setSelectedOrganisation(organisation: (weakSelf.interactor.sessionRepository.getSession()?.selectedOrganisation)!)
                weakSelf.view?.navigateToSelectedOrganisation()
            }
            else{
                guard let weakSelf = self else { return }
                weakSelf.view?.showErrorLoadingSelectedOrganisationPopup(message: "There were no matches for this ID.")
            }
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.view?.showErrorLoadingSelectedOrganisationPopup(message: "There was an error loading organization. Please try again.")
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.removeOrganisationLoadingView()
        }
    }
    
    func configureNotifications() {
        NotificationsPermissionUtil.getNotificationsAuthorizationStatus { (status) in
            DispatchQueue.main.async {
                if status == .notDetermined {
                    //ask first time popup
                    let askedToEnableNotifications = self.interactor.hasAskedEnableNotificationsPopup()
                    if askedToEnableNotifications == false {
                        self.view?.showPreNotificationsPermissionPopup()
                        self.interactor.setAskedEnableNotificationsPopup(shown: true)
                    }
                } else if status == .authorized {
                    //re-register device after logging in
                    self.registerDeviceForNotifications()
                }
            }
        }
    }
    
    func respondedToNotificationsPermissionPopup(success: Bool) {
        print("notifications permission: \(success)")
        
        switch success {
        case true:
            registerDeviceForNotifications()
        case false:
            break
        }
    }
    
    fileprivate func registerDeviceForNotifications() {
        interactor.registerDeviceForPushNotifications().done { response in
        }.catch { error in
            print(error)
        }
    }
    
    func logoutBtnPressed() {
        logoutUser()
    }
    
    func logoutActionPressed() {
        logoutUser()
    }
    
    fileprivate func logoutUser() {
        interactor.logoutUser().done { response in
        }.catch { error in
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.changeToLoginVC()
        }
    }
    
    func webViewOpenedLinkToNativePage(url: String) {
        let endpoint = NavigationUtil().getEndpointAfterScheme(url: url)
        if endpoint == "joinedorganization" {
            //close webview and refresh list
            view?.closeWebView()
            //            getOrganisations()
        }
    }
    
    fileprivate func showEntries() {
//        self.shownOrganisations = orgnaisationsToShow()
        view?.setOrganisationsArray(organisations: self.shownOrganisations)
        
        if self.shownOrganisations.count == 0 {
            let title = "No Organizations Found"
            var message = "There are no organizations matching your search term."
            view?.showEmptyPlaceholderView(title: title, message: message)
        } else {
            view?.removeEmptyPlaceholderView()
        }
    }
    
    
//    fileprivate func orgnaisationsToShow() -> Array<Org> {
//        if searchTerm != nil {
//            //            return searchOrganisations(organisations: organisations)
//        } else {
//            return organisations
//        }
//    }
    
    
//    fileprivate func searchOrganisations(Org: Array<Org>) -> Array<Org> {
        //        guard let searchTerm = self.searchTerm else { return [] }
        //        let lowercasedSearchTerm = searchTerm.lowercased()
        //
        //        let searchedOrganisations = organisations.filter({ (organisation) -> Bool in
        //
        //            let parentNamesString = organisation.name?.lowercased() ?? ""
        //            let parentNameString = organisation
        //            if parentNamesString.contains(lowercasedSearchTerm) {
        //                view?.toggleFooterView(show: true)
        //                return true
        //            }
        //            else{
        //                view?.toggleFooterView(show: false)
        //                return false
        //            }
        //        })
        
        //        return sortOrgnaisations(organisations: searchedOrganisations)
        //    }
        
        //    fileprivate func sortOrgnaisations(organisations: Array<Org>) -> Array<Org> {
        //        return organisations.sorted(by: { $0.org_name ?? "" > $1.org_name ?? "" })
        //    }
        
        //    fileprivate func setSearchTerm(searchTerm: String) {
        //        if searchTerm == "" {
        //            view?.toggleFooterView(show: true)
        //            self.searchTerm = nil
        //        } else {
        //            self.searchTerm = searchTerm
        //        }
        //    }
        //
        //    func getSearchedOrganisationCodeId(searchTerm: String) -> Org? {
        //        return organisations.filter { $0.org_name == searchTerm }.first ?? nil
        //    }
        //
        //    func searchBtnPressed(searchTerm: String, isAdmin: Bool?) {
        //        setSearchTerm(searchTerm: searchTerm)
        //
        //        var user = interactor.sessionRepository.getSession()?.userInfo
        //        if(user?.mtkAdmin != nil && user?.mtkAdmin != false){
        //            if((searchTerm.count > 3)&&(searchTerm.isInt)){
        //
        //                    didSelectOrganisationWithId(organisationID: searchTerm)
        //
        //            }
        //            else{
        //                showEntries()
        //            }
        //        }
        //        else{
        //            if((searchTerm.count > 3)&&(searchTerm.isInt)){
        //                let organisation = getSearchedOrganisationCodeId(searchTerm: searchTerm)
        //                if(organisation != nil){
        ////                    didSelectOrganisation(organisation: organisation!)
        //                }
        //                else{
        //                    showEntries()
        //                }
        //            }
        //            else{
        //                showEntries()
        //            }
        //        }
        //
        //
        //
        //        view?.dismissSearchBar()
        //    }
        
//        func searchTermDidChange(searchTerm: String) {
//            setSearchTerm(searchTerm: searchTerm)
//            showEntries()
//        }
//        
//        func cancelSearchBtnPressed() {
//            searchTerm = nil
//            view?.dismissSearchBar()
//            
//            showEntries()
//        }
//    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
