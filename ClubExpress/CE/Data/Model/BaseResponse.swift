//
//  BaseResponse.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation

class BaseResponse: Decodable {
    let success: Bool?
    let errorCode: String?
    let errorMessage: String?
    let errorUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case success = "success"
        case errorCode = "err"
        case errorMessage = "err_msg"
        case errorUrl = "err_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let success = try container.decodeIfPresent(Bool.self, forKey: .success) {
            self.success = success
        } else {
            self.success = nil
        } 
        self.errorCode = try? container.decode(String.self, forKey: .errorCode)
        self.errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        self.errorUrl = try? container.decode(String.self, forKey: .errorUrl)
    }
}
