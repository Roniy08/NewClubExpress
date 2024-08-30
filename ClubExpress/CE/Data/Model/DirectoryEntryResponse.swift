//
//  DirectoryEntryResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntryResponse: Decodable {
    let parentData: Dictionary<String, String?>?
    let parentsFieldList: Array<DirectoryEntryResponseDetailField>?
    let studentsFieldList: Array<DirectoryEntryResponseDetailField>?
    let studentData: Array<Dictionary<String, String?>>?
    let labels: DirectoryEntryResponseLabel?
    let ads: Array<NativeAd>?
    let isFavourite: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case parentsFieldList = "parent_field_list"
        case parentData = "parents"
        case studentsFieldList = "student_field_list"
        case studentData = "students"
        case labels = "labels"
        case isFavourite = "is_favorite"
        case ads = "show-ad"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parentsFieldList = try? container.decode(Array<DirectoryEntryResponseDetailField>.self, forKey: .parentsFieldList)
        self.parentData = try? container.decode(Dictionary<String, String?>.self, forKey: .parentData)
        self.studentsFieldList = try? container.decode(Array<DirectoryEntryResponseDetailField>.self, forKey: .studentsFieldList)
        self.studentData = try? container.decode(Array<Dictionary<String, String?>>.self, forKey: .studentData)
        self.labels = try? container.decode(DirectoryEntryResponseLabel.self, forKey: .labels)
        self.isFavourite = try? container.decode(Bool.self, forKey: .isFavourite)
        self.ads = try? container.decode(Array<NativeAd>.self, forKey: .ads)
    }
}
