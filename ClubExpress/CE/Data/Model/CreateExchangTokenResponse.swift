//
//  CreateExchangTokenResponse.swift
//  CE
//
//  Created by Ronit Patel on 19/06/24.
//  Copyright © 2024 Zeta. All rights reserved.
//

import Foundation
class CreateExchangTokenResponse: BaseResponse {
    let tempToken: String
    let orgId: String
    let memberId: String
    
    private enum CodingKeys: String, CodingKey {
        case tempToken = "temp_token"
        case orgId = "org_id"
        case memberId = "member_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tempToken = try container.decode(String.self, forKey: .tempToken)
        self.orgId = try container.decode(String.self, forKey: .orgId)
        self.memberId = try container.decode(String.self, forKey: .memberId)
        try super.init(from: decoder)
    }
}
