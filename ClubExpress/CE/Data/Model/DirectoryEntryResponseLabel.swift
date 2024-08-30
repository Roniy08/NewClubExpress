//
//  DirectoryEntryResponseLabel.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntryResponseLabel: Decodable {
    let parent1: String?
    let parent2: String?
    let student: DirectoryEntryResponseLabelStudent?
    
    private enum CodingKeys: String, CodingKey {
        case parent1 = "parent1"
        case parent2 = "parent2"
        case student = "student"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parent1 = try? container.decode(String.self, forKey: .parent1)
        self.parent2 = try? container.decode(String.self, forKey: .parent2)
        self.student = try? container.decode(DirectoryEntryResponseLabelStudent.self, forKey: .student)
    }
}

