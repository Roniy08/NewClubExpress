//
//  LocationIdResponse.swift
// ClubExpress
//
//  Created by Ronit Patel on 12/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
class LocationIdStripeResponse: Decodable {
    let status: Bool?
    let stripe_location_id: String?
    
    private enum CodingKeys: String, CodingKey {
        case status = "success"
        case stripe_location_id = "stripe_location_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let success = try container.decodeIfPresent(Bool.self, forKey: .status) {
            self.status = success
        } else {
            self.status = nil
        } 
        self.stripe_location_id = try? container.decode(String.self, forKey: .stripe_location_id)
    }
}
