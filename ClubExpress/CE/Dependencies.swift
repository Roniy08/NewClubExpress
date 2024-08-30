//
//  Dependencies.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 19/12/2018.
//  
//

import Foundation
import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {
    class func setup() {
        //Common
        defaultContainer.register(MembershipRemoteSource.self) { _ in MembershipAPI() }.inObjectScope(.container)
        defaultContainer.register(UserDefaultsSource.self) { _ in UserDefaultsSourceImpl() }.inObjectScope(.container)
        defaultContainer.register(FileSource.self) { _ in FileSourceImpl() }.inObjectScope(.container)
        defaultContainer.register(OrganisationColours.self) { _ in OrganisationColours() }.inObjectScope(.container)
        
        defaultContainer.register(DirectoryFiltersLocalSource.self) { _ in DirectoryFiltersLocalSourceImpl() }.inObjectScope(.container)

        defaultContainer.register(CalendarSettingsLocalSource.self) { _ in CalendarSettingsLocalSourceImpl() }.inObjectScope(.container)
        defaultContainer.register(CalendarEventsLocalSource.self) { _ in CalendarEventsLocalSourceImpl() }.inObjectScope(.container)
        
        defaultContainer.register(BasketLocalSource.self) { _ in return BasketLocalSourceImpl() }.inObjectScope(.container)
        
        defaultContainer.register(NotificationsToken.self) { _ in FirebaseNotificationsToken() }.inObjectScope(.container)
        
        defaultContainer.register(NotificationsCountLocalSource.self) { _ in return NotificationsCountLocalSourceImpl() }.inObjectScope(.container)
        
        //Repositories
        defaultContainer.register(SessionRepository.self) { r in
            return SessionRepository(userDefaultsSource: r.resolve(UserDefaultsSource.self)!, fileSource: r.resolve(FileSource.self)!, organisationColours: r.resolve(OrganisationColours.self)!)
        }.inObjectScope(.container)
        
        defaultContainer.register(OrganisationsRepository.self) { r in
            return OrganisationsRepository(membershipRemoteSource: r.resolve(MembershipRemoteSource.self)!)
        }.inObjectScope(.container)
        
        defaultContainer.register(LoginRepository.self) { r in
            return LoginRepository(membershipRemoteSource: r.resolve(MembershipRemoteSource.self)!, userDefaultsSource: r.resolve(UserDefaultsSource.self)!)
        }.inObjectScope(.container)
        
        defaultContainer.register(DirectoryRepository.self) { r in
            return DirectoryRepository(membershipRemoteSource: r.resolve(MembershipRemoteSource.self)!, directoryFiltersLocalSource: r.resolve(DirectoryFiltersLocalSource.self)!)
        }.inObjectScope(.container)
        
        defaultContainer.register(CalendarRepository.self) { r in
            return CalendarRepository(userDefaultsSource: r.resolve(UserDefaultsSource.self)!, membershipRemoteSource: r.resolve(MembershipRemoteSource.self)!, calendarSettingsLocalSource: r.resolve(CalendarSettingsLocalSource.self)!, calendarEventsLocalSource: r.resolve(CalendarEventsLocalSource.self)!)
            }.inObjectScope(.container)
        
        defaultContainer.register(BasketRepository.self) { r in
            return BasketRepository(basketLocalSource: r.resolve(BasketLocalSource.self)!)
            }.inObjectScope(.container)
        
        defaultContainer.register(NotificationsRepository.self) { r in
            return NotificationsRepository(membershipRemoteSource: r.resolve(MembershipRemoteSource.self)!, userDefaultsSource: r.resolve(UserDefaultsSource.self)!, notificationsToken: r.resolve(NotificationsToken.self)!)
            }.inObjectScope(.container)
        
        defaultContainer.register(NotificationsCountRepository.self) { r in
            return NotificationsCountRepository(notificationsCountLocalSource: r.resolve(NotificationsCountLocalSource.self)!)
        }.inObjectScope(.container)
        
        //Splash
        defaultContainer.register(SplashInteractor.self) { r in
            return SplashInteractor(sessionRepository: r.resolve(SessionRepository.self)!, directoryRepository: r.resolve(DirectoryRepository.self)!, calendarRepository: r.resolve(CalendarRepository.self)!, notificationsRepository: r.resolve(NotificationsRepository.self)!)
        }
        defaultContainer.register(RefreshOrgInteractor.self){ r in
            return RefreshOrgInteractor(organisationsRepository: r.resolve(OrganisationsRepository.self)!, sessionRepository: r.resolve(SessionRepository.self)!)
        }
        defaultContainer.register(SplashPresenter.self) { r in
            return SplashPresenter(interactor: r.resolve(SplashInteractor.self)!, refreshOrgInteractor: r.resolve(RefreshOrgInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(SplashViewController.self) { r, c in
            c.presenter = r.resolve(SplashPresenter.self)
        }
        
        //Login
        defaultContainer.register(LoginInteractor.self) { r in
            return LoginInteractor(loginRepository: r.resolve(LoginRepository.self)!, sessionRepository: r.resolve(SessionRepository.self)!, notificationRepositories: r.resolve(NotificationsRepository.self)!)
        }
        defaultContainer.register(LoginPresenter.self) { r in
            return LoginPresenter(interactor: r.resolve(LoginInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(LoginViewController.self) { r, c in
            c.presenter = r.resolve(LoginPresenter.self)
        }
        defaultContainer.storyboardInitCompleted(LoginNavigationController.self) { (_, _) in }
        
        //Organisations
        defaultContainer.register(OrganisationsInteractor.self) { r in
            return OrganisationsInteractor(organisationsRepository: r.resolve(OrganisationsRepository.self)!, sessionRepository: r.resolve(SessionRepository.self)!, notificationsRepository: r.resolve(NotificationsRepository.self)!, loginRepository: r.resolve(LoginRepository.self)!)
        }
        defaultContainer.register(OrganisationsPresenter.self) { r in
            return OrganisationsPresenter(interactor: r.resolve(OrganisationsInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(OrganisationsViewController.self) { r, c in
            c.presenter = r.resolve(OrganisationsPresenter.self)
        }
        
        //Organisation Wrapper
        defaultContainer.register(OrganisationWrapperInteractor.self) { r in
            return OrganisationWrapperInteractor(sessionRepository: r.resolve(SessionRepository.self)!, loginRepository: r.resolve(LoginRepository.self)!, directoryRepository: r.resolve(DirectoryRepository.self)!, calendarRepository: r.resolve(CalendarRepository.self)!, basketRepository: r.resolve(BasketRepository.self)!, organisationsRepository: r.resolve(OrganisationsRepository.self)!, notificationsCountRepository: r.resolve(NotificationsCountRepository.self)!, notificationsRepository: r.resolve(NotificationsRepository.self)!)
        }
        defaultContainer.register(OrganisationWrapperPresenter.self) { r in
            return OrganisationWrapperPresenter(interactor: r.resolve(OrganisationWrapperInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(OrganisationWrapperViewController.self) { (r, c) in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(OrganisationWrapperPresenter.self)
        }
        defaultContainer.storyboardInitCompleted(OrganisationNavigationController.self) { (r, c) in
            c.organisationColours = r.resolve(OrganisationColours.self)
        }
        
        //Menu
        defaultContainer.register(MenuInteractor.self) { r in
            return MenuInteractor(sessionRepository: r.resolve(SessionRepository.self)!, basketRepository: r.resolve(BasketRepository.self)!, notificationsCountRepository: r.resolve(NotificationsCountRepository.self)!)
        }
        defaultContainer.register(MenuPresenter.self) { r in
            return MenuPresenter(interactor: r.resolve(MenuInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(MenuViewController.self) { (r, c) in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(MenuPresenter.self)
        }
        
        //Web Content
        defaultContainer.register(WebContentInteractor.self) { r in
            return WebContentInteractor(sessionRepository: r.resolve(SessionRepository.self)!, basketRepository: r.resolve(BasketRepository.self)!)
        }
        defaultContainer.register(WebContentPresenter.self) { r in
            return WebContentPresenter(interactor: r.resolve(WebContentInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(WebContentViewController.self) { (r, c) in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(WebContentPresenter.self)
        }
        
        //Directory
        defaultContainer.register(DirectoryInteractor.self) { r in
            return DirectoryInteractor(sessionRepository: r.resolve(SessionRepository.self)!, directoryRepository: r.resolve(DirectoryRepository.self)!)
        }
        defaultContainer.register(DirectoryPresenter.self) { r in
            return DirectoryPresenter(interactor: r.resolve(DirectoryInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(DirectoryViewController.self) { r, c in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(DirectoryPresenter.self)
        }
        
        //Directory Filters
        defaultContainer.register(DirectoryFiltersInteractor.self) { r in
            return DirectoryFiltersInteractor(sessionRepository: r.resolve(SessionRepository.self)!, directoryRepository: r.resolve(DirectoryRepository.self)!)
        }
        defaultContainer.register(DirectoryFiltersPresenter.self) { r in
            return DirectoryFiltersPresenter(interactor: r.resolve(DirectoryFiltersInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(DirectoryFiltersViewController.self) { r, c in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(DirectoryFiltersPresenter.self)
        }
        
        //Directory Detail
        defaultContainer.register(DirectoryDetailInteractor.self) { r in
            return DirectoryDetailInteractor(sessionRepository: r.resolve(SessionRepository.self)!, directoryRepository: r.resolve(DirectoryRepository.self)!)
        }
        defaultContainer.register(DirectoryDetailPresenter.self) { r in
            return DirectoryDetailPresenter(interactor: r.resolve(DirectoryDetailInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(DirectoryDetailViewController.self) { r, c in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(DirectoryDetailPresenter.self)
        }
        
        //Calendar
        defaultContainer.register(CalendarInteractor.self) { r in
            return CalendarInteractor(sessionRepository: r.resolve(SessionRepository.self)!, calendarRepository: r.resolve(CalendarRepository.self)!)
        }
        defaultContainer.register(CalendarPresenter.self) { r in
            return CalendarPresenter(interactor: r.resolve(CalendarInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(CalendarViewController.self) { r, c in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(CalendarPresenter.self)
        }
        
        //Calendar Settings
        defaultContainer.register(CalendarSettingsInteractor.self) { r in
            return CalendarSettingsInteractor(sessionRepository: r.resolve(SessionRepository.self)!, calendarRepository: r.resolve(CalendarRepository.self)!)
        }
        defaultContainer.register(CalendarSettingsPresenter.self) { r in
            return CalendarSettingsPresenter(interactor: r.resolve(CalendarSettingsInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(CalendarSettingsViewController.self) { r, c in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(CalendarSettingsPresenter.self)
        }
        
        //Calendar Grid
        defaultContainer.register(CalendarGridInteractor.self) { r in
            return CalendarGridInteractor(sessionRepository: r.resolve(SessionRepository.self)!, calendarRepository: r.resolve(CalendarRepository.self)!)
        }
        defaultContainer.register(CalendarGridPresenter.self) { r in
            return CalendarGridPresenter(interactor: r.resolve(CalendarGridInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(CalendarGridViewController.self) { r, c in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(CalendarGridPresenter.self)
        }
        
        //Calendar Event
        defaultContainer.register(CalendarEventPresenter.self) { r in
            return CalendarEventPresenter()
        }
        defaultContainer.storyboardInitCompleted(CalendarEventViewController.self) { r, c in
            c.presenter = r.resolve(CalendarEventPresenter.self)
        }
        
        //Calendar Event Content
        defaultContainer.register(CalendarEventContentInteractor.self) { r in
            return CalendarEventContentInteractor(sessionRepository: r.resolve(SessionRepository.self)!, calendarRepository: r.resolve(CalendarRepository.self)!)
        }
        defaultContainer.register(CalendarEventContentPresenter.self) { r in
            return CalendarEventContentPresenter(interactor: r.resolve(CalendarEventContentInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(CalendarEventContentViewController.self) { r, c in
            c.presenter = r.resolve(CalendarEventContentPresenter.self)
        }
        
        //Settings
        defaultContainer.register(SettingsInteractor.self) { r in
            return SettingsInteractor(sessionRepository: r.resolve(SessionRepository.self)!, notificationsRepository: r.resolve(NotificationsRepository.self)!)
        }
        defaultContainer.register(SettingsPresenter.self) { r in
            return SettingsPresenter(interactor: r.resolve(SettingsInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(SettingsViewController.self) { r, c in
            c.organisationColours = r.resolve(OrganisationColours.self)
            c.presenter = r.resolve(SettingsPresenter.self)
        }
        
        //Notifications Org Switcher
        defaultContainer.register(NotifOrgSwitcherInteractor.self) { r in
            return NotifOrgSwitcherInteractor(sessionRepository: r.resolve(SessionRepository.self)!)
        }
        defaultContainer.register(NotifOrgSwitcherPresenter.self) { r in
            return NotifOrgSwitcherPresenter(interactor: r.resolve(NotifOrgSwitcherInteractor.self)!, refreshOrgInteractor: r.resolve(RefreshOrgInteractor.self)!)
        }
        defaultContainer.storyboardInitCompleted(NotifOrgSwitcherViewController.self) { r, c in
            c.presenter = r.resolve(NotifOrgSwitcherPresenter.self)
        }
    }
}
