//
//  DirectoryEntry.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntry: Decodable {
    let id: String?
    let firstName: String?
    let lastName: String?
    let title: String?
    let firstName2: String?
    let lastName2: String?
    let title2: String?
    let isFavourite: Bool?
    let students: Array<DirectoryStudent>?
    let sortKey: Int?
    let row1Text: String?
    let row2Text: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "member_id"
        case firstName = "firstname"
        case lastName = "lastname"
        case title = "title"
        case firstName2 = "firstname2"
        case lastName2 = "lastname2"
        case title2 = "title2"
        case students = "students"
        case isFavourite = "is_favorite"
        case sortKey = "sort_key"
        case row1Text = "row1_text"
        case row2Text = "row2_text"
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let apostrophesCharacterSet = CharacterSet(charactersIn: "'‘’`'\"")
        self.id = try? container.decode(String.self, forKey: .id)
        if let firstName = try? container.decode(String.self, forKey: .firstName), firstName != "" {
            if let _ = firstName.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringfirstName = firstName.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.firstName = convertedStringfirstName
            } else {
                self.firstName = firstName
            }
        } else {
            self.firstName = nil
        }
        if let lastName = try? container.decode(String.self, forKey: .lastName), lastName != "" {
            if let _ = lastName.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringlastName = lastName.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.lastName = convertedStringlastName
            } else {
                self.lastName = lastName
            }
        } else {
            self.lastName = nil
        }
        if let title = try? container.decode(String.self, forKey: .title), title != "" {
            if let _ = title.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringTitle = title.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.title = convertedStringTitle
            } else {
                self.title = title
            }
        } else {
            self.title = nil
        }
        if let firstName2 = try? container.decode(String.self, forKey: .firstName2), firstName2 != "" {
            if let _ = firstName2.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringfirstName2 = firstName2.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.firstName2 = convertedStringfirstName2
            } else {
                self.firstName2 = firstName2
            }
        } else {
            self.firstName2 = nil
        }
        if let lastName2 = try? container.decode(String.self, forKey: .lastName2), lastName2 != "" {
            if let _ = lastName2.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringlastName2 = lastName2.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.lastName2 = convertedStringlastName2
            } else {
                self.lastName2 = lastName2
            }
        } else {
            self.lastName2 = nil
        }
        if let title2 = try? container.decode(String.self, forKey: .title2), title2 != "" {
            if let _ = title2.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringTitle2 = title2.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.title2 = convertedStringTitle2
            } else {
                self.title2 = title2
            }
        } else {
            self.title2 = nil
        }
        self.students = try? container.decode(Array<DirectoryStudent>.self, forKey: .students)
        self.isFavourite = try? container.decode(Bool.self, forKey: .isFavourite)
        self.sortKey = try? container.decode(Int.self, forKey: .sortKey)
        if let row1Text = try? container.decode(String.self, forKey: .row1Text), row1Text != "" {
            if let _ = row1Text.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringrow1Text = row1Text.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.row1Text = convertedStringrow1Text
            } else {
                self.row1Text = row1Text
            }
        } else {
            self.row1Text = nil
        }
        if let row2Text = try? container.decode(String.self, forKey: .row2Text), row2Text != "" {
            if let _ = row2Text.rangeOfCharacter(from: apostrophesCharacterSet) {
                let convertedStringrow2Text = row2Text.components(separatedBy: apostrophesCharacterSet).joined(separator: "'")
                self.row2Text = convertedStringrow2Text
            } else {
                self.row2Text = row2Text
            }
        } else {
            self.row2Text = nil
        }
    }
}
