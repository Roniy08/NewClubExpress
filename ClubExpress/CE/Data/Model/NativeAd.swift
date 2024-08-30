//
//  NativeAd.swift
// ClubExpress
//
//  Created by Hayd Gately on 08/06/2021.
//  Copyright © 2021 Zeta. All rights reserved.
//

import Foundation

class NativeAd: Decodable {
    let href: String?
    let imgSrc: String?
    let width: Int?
    let height: Int?
    let adWidth: Int?
    let adHeight: Int?
    let position: String?

    private enum CodingKeys: String, CodingKey {
        case href = "href"
        case imgSrc = "img-src"
        case width = "width"
        case height = "height"
        case adWidth = "ad-width"
        case adHeight = "ad-height"
        case position = "position"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let href = try? container.decode(String.self, forKey: .href), href != "" {
            self.href = href
        } else {
            self.href = nil
        }
        if let imgSrc = try? container.decode(String.self, forKey: .imgSrc), imgSrc != "" {
            self.imgSrc = imgSrc
        } else {
            self.imgSrc = nil
        }
        if let width = try? container.decode(Int.self, forKey: .width), width != 0 {
            self.width = width
        } else {
            self.width = nil
        }
        if let height = try? container.decode(Int.self, forKey: .height), height != 0 {
            self.height = height
        } else {
            self.height = nil
        }
        if let adWidth = try? container.decode(Int.self, forKey: .adWidth), adWidth != 0 {
            self.adWidth = adWidth
        } else {
            self.adWidth = nil
        }
        if let adHeight = try? container.decode(Int.self, forKey: .adHeight), adHeight != 0 {
            self.adHeight = adHeight
        } else {
            self.adHeight = nil
        }
    
        self.position = try? container.decode(String.self, forKey: .position)
    }
}
