//
//  ConnectionTokenResponse.swift
// ClubExpress
//
//  Created by Ronit Patel on 16/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
class ConnectionTokenResponse: Decodable {
    let status: Bool?
    let connectionSecretString: String?
    
    private enum CodingKeys: String, CodingKey {
        case status = "success"
        case connectionSecret = "secret"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let success = try container.decodeIfPresent(Bool.self, forKey: .status) {
            self.status = success
        } else {
            self.status = nil
        }
        self.connectionSecretString = try? container.decode(String.self, forKey: .connectionSecret)
    }
}
