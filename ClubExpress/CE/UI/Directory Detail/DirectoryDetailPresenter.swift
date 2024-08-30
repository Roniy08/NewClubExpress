//
//  DirectoryDetailPresenter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import Contacts

protocol DirectoryDetailView: class {
    func toggleLoadingIndicator(loading: Bool)
    func showErrorLoadingDirectoryEntryPopup(message: String)
    func showErrorFavouritingEntryPopup(message: String)
    func endRefreshControlAnimating()
    func setTitle(title: String)
    func showAds(ads: Array<NativeAd>)
    func setEntrySections(sections: Array<DirectoryEntrySection>)
    func setHeaderLabels(labels: DirectoryEntryLabels)
    func showPhoneActionSheet(number: String, sourceView: DirectoryFieldView, sourceFrame: CGRect)
    func showMapsActionSheet(address: String, sourceView: DirectoryFieldView, sourceFrame: CGRect)
    func openSystemUrl(url: String)
    func scrollToNextPerson()
    func toggleScrollBtn(visible: Bool)
    func showAddContactPopup(contact: CNMutableContact)
    func toggleIsFavouritedButton(favourited: Bool)
    func sendDidChangeFavourited()
}

class DirectoryDetailPresenter {
    weak var view: DirectoryDetailView?
    fileprivate var interactor: DirectoryDetailInteractor
    fileprivate var entryID: String?
    fileprivate var entryName: String?
    fileprivate var directoryEntryDetails: DirectoryEntryDetails?
    fileprivate var sections = Array<DirectoryEntrySection>()
    fileprivate var scrollBtnVisible = false
    fileprivate var didChangeFavourited = false
    
    init(interactor: DirectoryDetailInteractor) {
        self.interactor = interactor
    }
    
    func viewDidLoad(entryID: String, entryName: String) {
        self.entryID = entryID
        self.entryName = entryName
        
        view?.setTitle(title: entryName)
        
        getDirectoryDetail()
    }
    
    func viewWillDisappear() {
        if didChangeFavourited {
            view?.sendDidChangeFavourited()
        }
    }
    
    func getDirectoryDetail(refreshing: Bool = false) {
        guard let id = entryID else { return }
        if refreshing == false {
            view?.toggleLoadingIndicator(loading: true)
        }
        view?.toggleScrollBtn(visible: false)
        
        interactor.getDirectoryEntry(memberID: id).done { [weak self] (directoryEntryDetails) in
            guard let weakSelf = self else { return }
            weakSelf.directoryEntryDetails = directoryEntryDetails
            
            var sections = Array<DirectoryEntrySection>()
            
            //Parent 1 section
            if let parent1 = directoryEntryDetails.parent1 {
                let parent1Label = directoryEntryDetails.labels?.parent1 ?? ""
                let parent1Section = DirectoryEntrySection(headerLabel: parent1Label, people: [parent1])
                sections.append(parent1Section)
            }
            
            //Parent 2 section
            if let parent2 = directoryEntryDetails.parent2 {
                let parent2Label = directoryEntryDetails.labels?.parent2 ?? ""
                let parent2Section = DirectoryEntrySection(headerLabel: parent2Label, people: [parent2])
                sections.append(parent2Section)
            }
            
            //Students section
            var studentLabel = directoryEntryDetails.labels?.studentSingular ?? ""
            if directoryEntryDetails.students.count > 0 {
                studentLabel = directoryEntryDetails.labels?.studentPlural ?? ""
                let students = directoryEntryDetails.students
                let studentsSection = DirectoryEntrySection(headerLabel: studentLabel, people: students)
                sections.append(studentsSection)
            }
            
            weakSelf.sections = sections
            weakSelf.view?.setEntrySections(sections: sections)
            weakSelf.setupScrollBtn()
            weakSelf.setAds(ads: directoryEntryDetails.ads ?? [])
            if let labels = directoryEntryDetails.labels {
                weakSelf.view?.setHeaderLabels(labels: labels)
            }
            
            weakSelf.configureFavouriteButton()
        }.catch { [weak self] (error) in
            guard let weakSelf = self else { return }
            let errorMessage = "There was an error loading the directory entry. Please try again."
            weakSelf.view?.showErrorLoadingDirectoryEntryPopup(message: errorMessage)
        }.finally { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.toggleLoadingIndicator(loading: false)
            weakSelf.view?.endRefreshControlAnimating()
        }
    }
    
    func setAds(ads: Array<NativeAd>) {
        view?.showAds(ads: ads)
    }
    
    func pulledToRefresh() {
        getDirectoryDetail(refreshing: true)
    }
    
    func didPressField(fieldView: DirectoryFieldView, field: DirectoryEntryField, sourceFrame: CGRect) {
        guard let type = field.type else { return }
        guard let value = field.value else { return }

        switch type {
        case .phone:
            view?.showPhoneActionSheet(number: value, sourceView: fieldView, sourceFrame: sourceFrame)
        case .email:
            view?.openSystemUrl(url: "mailto:\(value)")
        case .address:
            view?.showMapsActionSheet(address: value, sourceView: fieldView, sourceFrame: sourceFrame)
            break
        case .text:
            break
        }
    }
    
    func callPhoneNumberActionPressed(number: String) {
        let stripppedNumber = stripNumber(number: number)
        view?.openSystemUrl(url: "telprompt://\(stripppedNumber)")
    }
    
    func messagePhoneNumberActionPressed(number: String) {
        let stripppedNumber = stripNumber(number: number)
        view?.openSystemUrl(url: "sms://\(stripppedNumber)")
    }
    
    fileprivate func stripNumber(number: String) -> String {
        return number.filter({ (character) -> Bool in
            return !"()- ".contains(character)
        })
    }
    
    func openAppleMapsActionPressed(address: String) {
        var encodedValue = address.replacingOccurrences(of: "\n", with: "%20")
        encodedValue = encodedValue.replacingOccurrences(of: " ", with: "+")
        let fullUrl = "http://maps.apple.com/?q=\(encodedValue)"
        view?.openSystemUrl(url: fullUrl)
    }
    
    func openGoogleMapsActionPressed(address: String) {
        var encodedValue = address.replacingOccurrences(of: "\n", with: "%20")
        encodedValue = encodedValue.replacingOccurrences(of: " ", with: "+")
        encodedValue = encodedValue.replacingOccurrences(of: ",", with: "%2C")
        let fullUrl = "https://www.google.com/maps/search/?api=1&query=\(encodedValue)"
        view?.openSystemUrl(url: fullUrl)
    }
    
    func scrollBtnPressed() {
        view?.scrollToNextPerson()
    }
    
    func tableViewDidScroll(offset: CGFloat, maxScrollOffset: CGFloat) {
        if offset > maxScrollOffset {
            if scrollBtnVisible == true {
                scrollBtnVisible = false
                view?.toggleScrollBtn(visible: false)
            }
        } else {
            if scrollBtnVisible == false {
                scrollBtnVisible = true
                view?.toggleScrollBtn(visible: true)
            }
        }
    }
    
    fileprivate func setupScrollBtn() {
        if sections.count > 1 {
            scrollBtnVisible = true
            view?.toggleScrollBtn(visible: true)
        } else {
            scrollBtnVisible = false
            view?.toggleScrollBtn(visible: false)
        }
    }
    
    func didPressAddContact(person: DirectoryEntryPerson, imageData: Data?) {
        let fields = person.fields
        var contact = DirectoryContact()

        fields.forEach { (field) in
            guard let name = field.name else { return }
            guard let value = field.value else { return }
            switch name {
            case "firstname", "firstname2":
                contact.firstName = value
            case "lastname", "lastname2":
                contact.lastName = value
            case "email", "email2":
                contact.email = value
            case "address", "address2":
                contact.address = value
            case "city", "city2":
                contact.city = value
            case "state", "state2":
                contact.state = value
            case "zip", "zip2":
                contact.zip = value
            case "phone_home", "phone_home2":
                contact.homePhone = stripNumber(number: value)
            case "phone_work", "phone_work2":
                contact.workPhone = stripNumber(number: value)
            case "phone_cell", "phone_cell2":
                contact.cellPhone = stripNumber(number: value)
            default:
                break
            }
        }
        
        if let imageData = imageData {
            contact.imageData = imageData
        }

        createContactForAddContact(contact: contact)
    }
    
    func createContactForAddContact(contact: DirectoryContact) {
        let addContact = CNMutableContact()
        
        if let firstName = contact.firstName {
            addContact.givenName = firstName
        }
        if let lastName = contact.lastName {
            addContact.familyName = lastName
        }
        
        if let emailAddress = contact.email {
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: (emailAddress as NSString))
            addContact.emailAddresses = [homeEmail]
        }
        
        let address = CNMutablePostalAddress()
        if let firstLineAddress = contact.address {
            address.street = firstLineAddress
        }
        if let city = contact.city {
            address.city = city
        }
        if let state = contact.state {
            address.state = state
        }
        if let zip = contact.zip {
            address.postalCode = zip
        }
        let postalAddress = CNLabeledValue<CNPostalAddress>(label: CNLabelHome, value: address)
        addContact.postalAddresses = [postalAddress]
        
        var phoneNumbers = Array<CNLabeledValue<CNPhoneNumber>>()
        if let workPhoneString = contact.workPhone {
            phoneNumbers.append(CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: workPhoneString)))
        }
        if let homePhoneString = contact.homePhone {
            phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: homePhoneString)))
        }
        if let cellPhoneString = contact.cellPhone {
            phoneNumbers.append(CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: cellPhoneString)))
        }
        addContact.phoneNumbers = phoneNumbers
        
        if let organisationName = interactor.getOrganisationName() {
            addContact.organizationName = organisationName
        }
        
        if let imageData = contact.imageData {
            addContact.imageData = imageData
        }
        
        view?.showAddContactPopup(contact: addContact)
    }
    
    fileprivate func configureFavouriteButton() {
        if let isFavourited = directoryEntryDetails?.isFavourite {
            view?.toggleIsFavouritedButton(favourited: isFavourited)
        } else {
            view?.toggleIsFavouritedButton(favourited: false)
        }
    }
    
    func favouriteEntryPressed() {
        toggleDirectoryEntryFavourite(favourited: true)
    }
    
    func unfavouriteEntryPressed() {
        toggleDirectoryEntryFavourite(favourited: false)
    }
    
    fileprivate func toggleDirectoryEntryFavourite(favourited: Bool) {
        guard let id = entryID else { return }
        
        interactor.toggleDirectoryEntryFavourite(memberID: id, favourited: favourited).done { [weak self] _ in
            guard let weakSelf = self else { return }
            
            weakSelf.directoryEntryDetails?.isFavourite = favourited
            weakSelf.didChangeFavourited = true
            
            }.catch { [weak self] (error) in
                guard let weakSelf = self else { return }
                let errorMessage = "There was an error favoriting this entry. Please try again."
                weakSelf.view?.showErrorFavouritingEntryPopup(message: errorMessage)
            }.finally { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.configureFavouriteButton()
        }
    }
}
