//
//  APIService.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import Combine

let API_Key = "d30196018ffea96c0d32f84262af7fe6"
let ROOT = "https://api.yelp.com/v3/businesses"

struct Endpoint {
    static let fetchBusinesses: (_ location: String, _ limit: Int) -> String = { location, limit in
        return "\(ROOT)/search/?location=\(location)&limit=\(limit)"
    }

}

enum Error: Swift.Error {
    case invalidData
    case connectionError
}

protocol HTTPClient {
    func get(url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
}

class APIService: BusinessLoader {
    private var httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    private struct RootItem: Decodable {
        let businesses: [BusinessModel]
    }
    
    func fetchBusinesses(by location: String) -> AnyPublisher<[BusinessModel], Error> {
        let url = URL(string: Endpoint.fetchBusinesses(location, 10))!
        
        return Deferred {
            Future() { promise in
                self.httpClient.get(url: url) { response in
                    switch response {
                    case let .success(data):
                        if let root = try? JSONDecoder().decode(RootItem.self, from: data) {
                            promise(.success(root.businesses))
                        } else {
                            promise(.failure(.invalidData))
                        }
                    case .failure:
                        promise(.failure(.invalidData))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
}
