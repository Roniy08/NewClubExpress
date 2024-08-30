//
//  DirectoryStudent.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 15/01/2019.
//  
//

import Foundation

class DirectoryStudent: Decodable {
    let firstName: String?
    let lastName: String?
    let grade: Int?
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "firstname"
        case lastName = "lastname"
        case grade = "grade"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let firstName = try? container.decode(String.self, forKey: .firstName), firstName != "" {
            self.firstName = firstName
        } else {
            self.firstName = nil
        }
        if let lastName = try? container.decode(String.self, forKey: .lastName), lastName != "" {
            self.lastName = lastName
        } else {
            self.lastName = nil
        }
        if let grade = try? container.decode(Int.self, forKey: .grade), grade != nil {
            self.grade = grade
        } else {
            self.grade = 0
        }
    }
}

