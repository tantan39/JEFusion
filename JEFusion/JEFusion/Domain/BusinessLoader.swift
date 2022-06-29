//
//  BusinessLoader.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation

protocol BusinessLoader {
    func fetchBusinesses(by location: String, completion: (Result<[BusinessModel], Error>) -> Void)
}


class BusinessModel {
    let id: String
    let name: String
    let isLiked: Bool
    
    init(id: String, name: String, isLiked: Bool) {
        self.id = id
        self.name = name
        self.isLiked = isLiked
    }
}
