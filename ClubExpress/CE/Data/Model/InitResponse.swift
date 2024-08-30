//
//  InitResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 18/01/2019.
//  
//

import Foundation

class InitResponse: Decodable {
    let loginMessage: String?
    
    private enum CodingKeys: String, CodingKey {
        case loginMessage = "login_message"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.loginMessage = try? container.decode(String.self, forKey: .loginMessage)
    }
}
