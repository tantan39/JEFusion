//
//  Endpoint.swift
//  JEFusion
//
//  Created by Tan Tan on 7/27/22.
//

import Foundation

let ROOT = URL(string: "https://api.yelp.com/v3/businesses")!

enum Endpoint {
    case getBusiness(location: String, limit: Int)
    case reviews(id: String)
    
    func url(baseURL: URL) -> URL {
        switch self {
        case .getBusiness(let location, let limit):
            var component = URLComponents()
            component.scheme = baseURL.scheme
            component.host = baseURL.host
            component.path = baseURL.path + "/search"
            component.queryItems = [
                URLQueryItem(name: "location", value: "\(location)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ]
            return component.url!

        case .reviews(let id):
            return URL(string:"\(baseURL)/\(id)/reviews")!
        }
    }
}
