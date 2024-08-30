//
//  LoginResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 14/12/2018.
//  
//

//import Foundation
//
//class LoginResponse: BaseResponse {
//    let email: String?
//    let firstName: String?
//    let lastName: String?
//    let avatarUrl: String?
//    
//    private enum CodingKeys: String, CodingKey {
//          case email = "email"
//          case firstName = "firstname"
//          case lastName = "lastname"
//          case avatarUrl = "avatar_url"
//      /*  case sessionToken = "session_token"
//        case email = "email"
//        case firstName = "firstname"
//        case lastName = "lastname"
//        case avatarUrl = "avatar_url"*/
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.email = try? container.decode(String.self, forKey: .email)
//        self.firstName = try? container.decode(String.self, forKey: .firstName)
//        self.lastName = try? container.decode(String.self, forKey: .lastName)
//        self.avatarUrl = try? container.decode(String.self, forKey: .avatarUrl)
//        try super.init(from: decoder)
//    }
//}
import Foundation

class LoginResponse: BaseResponse {
    let counts: Int
    let orgs: [OrgLogin]
    
    private enum CodingKeys: String, CodingKey {
        case count
        case orgs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.counts = try container.decode(Int.self, forKey: .count)
        self.orgs = try container.decode([OrgLogin].self, forKey: .orgs)
        try super.init(from: decoder)
    }
}

