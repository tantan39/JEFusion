//
//  BusinessLoader.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import Combine

protocol BusinessLoader {
    func fetchBusinesses(by location: String) -> AnyPublisher<[BusinessModel], Error>
}
