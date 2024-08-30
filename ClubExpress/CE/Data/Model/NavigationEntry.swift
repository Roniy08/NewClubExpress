//
//  NavigationEntry.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class NavigationEntry: NSObject, NSCoding, Decodable {
    var id: Int?
    let label: String?
    let url: String?
    let entries: Array<NavigationEntry>?
    var level: Int?
    
    private enum CodingKeys: String, CodingKey {
        case label = "label"
        case url = "url"
        case entries = "menu_entries"
    }
    
    init(id: Int?, label: String?, url: String?, entries: Array<NavigationEntry>?, level: Int?) {
        self.id = id
        self.label = label
        self.url = url
        self.entries = entries
        self.level = level
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = nil
        self.label = try? container.decode(String.self, forKey: .label)
        self.url = try? container.decode(String.self, forKey: .url)
        self.entries = try? container.decode(Array<NavigationEntry>.self, forKey: .entries)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.label, forKey: "label")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.entries, forKey: "entries")
        aCoder.encode(self.level, forKey: "level")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as? Int
        let label = aDecoder.decodeObject(forKey: "label") as? String
        let url = aDecoder.decodeObject(forKey: "url") as? String
        let entries = aDecoder.decodeObject(forKey: "entries") as? Array<NavigationEntry>
        let level = aDecoder.decodeObject(forKey: "level") as? Int
        
        self.init(id: id, label: label, url: url, entries: entries, level: level)
    }
}
