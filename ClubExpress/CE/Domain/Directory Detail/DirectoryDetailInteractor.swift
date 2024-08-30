//
//  DirectoryDetailInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

enum DirectoryDetailError: Error {
    case sessionTokenError
    case noSelectedOrganisation
    case noDirectoryEntry
    case unknownError
    case errorMessage(message: String)
}

class DirectoryDetailInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var directoryRepository: DirectoryRepository
    
    init(sessionRepository: SessionRepository, directoryRepository: DirectoryRepository) {
        self.sessionRepository = sessionRepository
        self.directoryRepository = directoryRepository
    }
    
    func getDirectoryEntry(memberID: String) -> Promise<DirectoryEntryDetails> {

        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(DirectoryDetailError.sessionTokenError)
                return
            }
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(DirectoryDetailError.noSelectedOrganisation)
                return
            }
            
            directoryRepository.getDirectoryEntry(sessionToken: sessionToken, organisationID: organisationID, memberID: memberID).done { [weak self] response  in
                guard let weakSelf = self else { return }
                
                //Parents
                let parentData = response.parentData ?? [:]
                
                //create array of fields
                var parentFields = Array<DirectoryEntryField>()
                for (key, value) in parentData {
                    if let value = value, value.count > 0 {
                        //combine fields from parents data and parents cutom fields
                        let details = response.parentsFieldList?.first(where: { (detailField) -> Bool in
                            return key == detailField.name
                        })
                        let label = details?.label
                        let sortOrder = details?.sortOrder
                        
                        let fieldType = weakSelf.getFieldType(value: value)
                        let parentField = DirectoryEntryField(name: key, label: label, sortOrder: sortOrder, value: value, type: fieldType)
                        parentFields.append(parentField)
                    }
                }
                
                //split parents fields into parent 1 and 2
                var parent1Fields = parentFields.filter({ (field) -> Bool in
                    let fieldName = field.name ?? ""
                    return !fieldName.contains("2")
                }).sorted(by: { (fieldA, fieldB) -> Bool in
                    let sortOrderA = fieldA.sortOrder ?? 0
                    let sortOrderB = fieldB.sortOrder ?? 0
                    return sortOrderA < sortOrderB
                })
                
                var parent2Fields = parentFields.filter({ (field) -> Bool in
                    let fieldName = field.name ?? ""
                    return fieldName.contains("2")
                }).sorted(by: { (fieldA, fieldB) -> Bool in
                    let sortOrderA = fieldA.sortOrder ?? 0
                    let sortOrderB = fieldB.sortOrder ?? 0
                    return sortOrderA < sortOrderB
                })
                
                //group seperate address fields and replace with merged string
                let address1FieldNames = ["address", "city", "state", "zip"]
                parent1Fields = weakSelf.mergeAddressFields(fields: parent1Fields, addressFieldNames: address1FieldNames)
                let address2FieldNames = ["address2", "city2", "state2", "zip2"]
                parent2Fields = weakSelf.mergeAddressFields(fields: parent2Fields, addressFieldNames: address2FieldNames)
                
                var parent1: DirectoryEntryPerson?
                if parent1Fields.count > 0 {
                    parent1 = DirectoryEntryPerson(fields: parent1Fields, type: .parent)
                }
                
                var parent2: DirectoryEntryPerson?
                if parent2Fields.count > 0 {
                    parent2 = DirectoryEntryPerson(fields: parent2Fields, type: .parent)
                }
                
                //Students
                let studentsResponse = response.studentData ?? []
                var studentsArray = Array<DirectoryEntryPerson>()
                
                //Build up students from api response
                for studentData in studentsResponse {
                    //create array of fields
                    var studentFields = Array<DirectoryEntryField>()
                    for (key, value) in studentData {
                        if let value = value, value.count > 0 {
                            //combine fields from students data and students cutom fields
                            let details = response.studentsFieldList?.first(where: { (detailField) -> Bool in
                                return key == detailField.name
                            })
                            let label = details?.label
                            let sortOrder = details?.sortOrder
                            
                            let fieldType = weakSelf.getFieldType(value: value)
                            let studentField = DirectoryEntryField(name: key, label: label, sortOrder: sortOrder, value: value, type: fieldType)
                            studentFields.append(studentField)
                        }
                    }
                    
                    if studentFields.count > 0 {
                        //sort fields based on sort order
                        let sortedStudentFields = studentFields.sorted(by: { (fieldA, fieldB) -> Bool in
                            let sortOrderA = fieldA.sortOrder ?? 0
                            let sortOrderB = fieldB.sortOrder ?? 0
                            return sortOrderA < sortOrderB
                        })
                        
                        //create student with fields array
                        let student = DirectoryEntryPerson(fields: sortedStudentFields, type: .student)
                        studentsArray.append(student)
                    }
                }
                
                //Convert labels into model
                let labels = response.labels.map({ (responseLabel) -> DirectoryEntryLabels in
                    return DirectoryEntryLabels(parent1: responseLabel.parent1, parent2: responseLabel.parent2, studentSingular: responseLabel.student?.singular, studentPlural: responseLabel.student?.plural)
                })
                
               
                
                let isFavourite = response.isFavourite ?? false
                
                let directoryEntryDetails = DirectoryEntryDetails(parent1: parent1, parent2: parent2, students: studentsArray, labels: labels, isFavourite: isFavourite, ads: response.ads)
                seal.fulfill(directoryEntryDetails)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    fileprivate func getFieldType(value: String) -> directoryEntryFieldType {
        let types = NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue | NSTextCheckingResult.CheckingType.address.rawValue
        let detector = try? NSDataDetector(types: types)
        guard let detect = detector else { return .text }
        let matches = detect.matches(in: value, options: [], range: NSRange(location: 0, length: value.count))
        if let firstMatch = matches.first {
            if firstMatch.resultType == .phoneNumber {
                return .phone
            } else if firstMatch.resultType == .address {
                return .address
            } else if firstMatch.resultType == .link {
                if firstMatch.url?.scheme == "mailto" {
                    return .email
                }
            }
        }
        
        return .text
    }
    
    fileprivate func mergeAddressFields(fields: Array<DirectoryEntryField>, addressFieldNames: Array<String>) -> Array<DirectoryEntryField> {
        var updatedFields = fields
        var mergedAddressArray = Array<DirectoryEntryField>()
        var addressSortOrder = 0
        var addressIndex = 0
        
        //build merged address components from existing fields
        for (index, field) in fields.enumerated() {
            if field.name == addressFieldNames.first! {
                addressSortOrder = field.sortOrder ?? 0
                addressIndex = index
            }
            if let fieldName = field.name {
                if addressFieldNames.contains(fieldName) {
                    mergedAddressArray.append(field)
                }
            }
        }
        
        //create merged string
        if mergedAddressArray.count > 0 {
            var mergedAddressString = ""
            for (index, mergedAddressItem) in mergedAddressArray.enumerated() {
                mergedAddressString.append(mergedAddressItem.value ?? "")
                if mergedAddressItem.name == "city" || mergedAddressItem.name == "city2" {
                    mergedAddressString.append(", ")
                } else if index < (mergedAddressArray.count - 1) {
                    mergedAddressString.append("\n")
                }
            }
            let mergedAddressField = DirectoryEntryField(name: "mergedAddress", label: "Address", sortOrder: addressSortOrder, value: mergedAddressString, type: .address)
            updatedFields.insert(mergedAddressField, at: addressIndex)
        }
        
        return updatedFields
    }
    
    func getOrganisationName() -> String? {
        guard let session = sessionRepository.getSession() else { return nil }
        guard let selectedOrganisation = session.selectedOrganisation else { return nil }
        return selectedOrganisation.name
    }
    
    func toggleDirectoryEntryFavourite(memberID: String, favourited: Bool) -> Promise<Void> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(DirectoryDetailError.sessionTokenError)
                return
            }
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(DirectoryDetailError.noSelectedOrganisation)
                return
            }
            
            directoryRepository.toggleDirectoryEntryFavourite(sessionToken: sessionToken, organisationID: organisationID, memberID: memberID, favourited: favourited).done { response in
                if response.success == true {
                    seal.fulfill(())
                } else if let errorMessage = response.errorMessage {
                    seal.reject(DirectoryDetailError.errorMessage(message: errorMessage))
                } else {
                    seal.reject(DirectoryDetailError.unknownError)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
