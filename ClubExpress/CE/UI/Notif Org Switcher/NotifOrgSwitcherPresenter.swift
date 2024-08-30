//
//  NotifOrgSwitcherPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 26/03/2019.
//  
//

import Foundation

protocol NotifOrgSwitcherView: class {
    func showErrorSwitchingOrganisation()
    func gotoOrganisationWrapperAndPresentNotifiction(notification: ReceivedNotification)
    func changeToSplashVC()
}

class NotifOrgSwitcherPresenter {
    weak var view: NotifOrgSwitcherView?
    fileprivate var interactor: NotifOrgSwitcherInteractor
    fileprivate var refreshOrgInteractor: RefreshOrgInteractor
    var receivedNotification: ReceivedNotification?
    
    init(interactor: NotifOrgSwitcherInteractor, refreshOrgInteractor: RefreshOrgInteractor) {
        self.interactor = interactor
        self.refreshOrgInteractor = refreshOrgInteractor
    }
    
    func viewDidLoad() {
        switchToCorrectOrg()
    }
    
    fileprivate func switchToCorrectOrg() {
        if interactor.getSessionToken() == nil {
            //not logged in
            view?.changeToSplashVC()
            return
        }
        
        guard let receivedNotification = self.receivedNotification else { return }
        let newOrgID = receivedNotification.orgID

        refreshOrgInteractor.refreshOrganisationDetails(organisationID: newOrgID).done { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.view?.gotoOrganisationWrapperAndPresentNotifiction(notification: receivedNotification)
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.view?.showErrorSwitchingOrganisation()
            print(error)
        }
    }
    
    func dismissBtnPressed() {
        interactor.clearSelectedOrganisation()
        
        view?.changeToSplashVC()
    }
    
    func retrySwitchOrgBtnPressed() {
        switchToCorrectOrg()
    }
}

