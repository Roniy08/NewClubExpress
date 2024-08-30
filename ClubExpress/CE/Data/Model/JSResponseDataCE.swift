//
//  JSResponseDataCE.swift
//  CE
//
//  Created by Ronit Patel on 30/07/24.
//  Copyright © 2024 Zeta. All rights reserved.
//

import Foundation
class UserResponseJSDataCE {
    var command : String? = ""
    var dataContent : String? = ""
    
    
    init(_ command:String,dataContent:String) {
        self.command = command
        self.dataContent = dataContent
    }
    // Method to convert dataContent to a dictionary
      func dataContentToDictionary() -> [String: Any]? {
          guard let dataContent = dataContent else { return nil }
          
          if let data = dataContent.data(using: .utf8) {
              do {
                  let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                  return dictionary
              } catch {
                  print("Error converting dataContent to dictionary: \(error.localizedDescription)")
              }
          }
          return nil
      }
}
