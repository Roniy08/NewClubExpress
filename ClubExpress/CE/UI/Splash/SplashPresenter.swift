//
//  SplashPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol SplashView: class {
    func setupNavigationFlow(state: SessionState, isAdmin: Bool?)
    func showErrorRefreshingOrganisation()
    func clearErrorRefreshingOrganisation()
    func toggleLoadingIndicator(show: Bool)
}

enum SessionState {
    case login
    case selectOrganisation
    case home
}

class SplashPresenter {
    weak var view: SplashView?
    fileprivate var interactor: SplashInteractor
    fileprivate var refreshOrgInteractor: RefreshOrgInteractor
    
    init(interactor: SplashInteractor, refreshOrgInteractor: RefreshOrgInteractor) {
        self.interactor = interactor
        self.refreshOrgInteractor = refreshOrgInteractor
    }
    
    func viewDidLoad() {
        view?.clearErrorRefreshingOrganisation()
        setNavigationFlow()
    }
    
    func setNavigationFlow() {
        if let session = interactor.getSessionState() {
            if session.sessionToken != nil {
                if session.selectedOrganisation != nil {
                    //Home
                    //Refresh organisation details
                    refreshOrganisationDetails()
                } else {
                    //Select Organisation
                    view?.setupNavigationFlow(state: .home, isAdmin: true)
                }
            } else {
                //Login
                view?.setupNavigationFlow(state: .login, isAdmin: nil)
            }
        } else {
            //Login
            view?.setupNavigationFlow(state: .login, isAdmin: nil)
        }
    }
    
    fileprivate func refreshOrganisationDetails() {
        view?.clearErrorRefreshingOrganisation()
        view?.toggleLoadingIndicator(show: true)

        let selectedOrgID = interactor.getSelectedOrgID()
        
        refreshOrgInteractor.refreshOrganisationDetails(organisationID: selectedOrgID).done { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.view?.setupNavigationFlow(state: .home, isAdmin: weakSelf.interactor.getSessionState()?.userInfo?.mtkAdmin)
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.view?.showErrorRefreshingOrganisation()
            print(error)
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.toggleLoadingIndicator(show: false)
        }
        
    }
    
    func retryBtnPressed() {
        refreshOrganisationDetails()
    }
    
    func logoutBtnPressed() {
        interactor.removeLocalData()
        view?.setupNavigationFlow(state: .login, isAdmin: interactor.getSessionState()?.userInfo?.mtkAdmin)
    }
}
