//
//  Review.swift
//  JEFusion
//
//  Created by Tan Tan on 6/30/22.
//

import Foundation

struct Review: Decodable {
    let id: String
    let text: String
    let user: User
    
    struct User: Decodable {
        let id: String
        let name: String
    }
}
