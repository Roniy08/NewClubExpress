//
//  ExchangeTokenResponse.swift
//  CE
//
//  Created by Ronit Patel on 14/06/24.
//  Copyright © 2024 Zeta. All rights reserved.
//

import Foundation
class ExchangeTokenResponse: BaseResponse {
    let sessionToken: String
    let orgId: String
    let memberId: String
    let url: String
    
    private enum CodingKeys: String, CodingKey {
        case sessionToken = "session_token"
        case orgId = "org_id"
        case memberId = "member_id"
        case url
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sessionToken = try container.decode(String.self, forKey: .sessionToken)
        self.orgId = try container.decode(String.self, forKey: .orgId)
        self.memberId = try container.decode(String.self, forKey: .memberId)
        self.url = try container.decode(String.self, forKey: .url)
        try super.init(from: decoder)
    }
}
