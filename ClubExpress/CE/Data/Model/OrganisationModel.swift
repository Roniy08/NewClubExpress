//
//  OrganisationModel.swift
//  CE
//
//  Created by Ronit Patel on 13/06/24.
//  Copyright © 2024 Zeta. All rights reserved.
//

struct OrgLogin: Codable {
    let org_id: Int?
    let org_name: String
    let logo_img: String
    let member_id: Int
    let temp_token: String?
}

struct Response: Codable {
    let success: Bool
    let count: Int
    let orgs: [OrgLogin]
    
}
