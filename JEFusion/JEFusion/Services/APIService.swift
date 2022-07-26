//
//  APIService.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import JECore
import Foundation
import Combine

let API_Key = "kWcQi-_11RNr5HC7w8wAe-BQyxndGeGY84AGjtSq8JurIWBrXbCcyKLx02k0llcMTc2ytj-Yga-JUHNX1DP1voqPR2yPHxh0m7jhJFPJDV23fpPNBWXTAheM-qG8YnYx"
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

protocol HTTPClient {
    func get(url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
}

class APIService: BusinessLoader {
    private var httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    private struct RootItem: Decodable {
        let businesses: [BusinessModel]?
        let reviews: [Review]?
    }
    
    func fetchBusinesses(by location: String) -> AnyPublisher<[BusinessModel], Error> {
        let url = Endpoint.getBusiness(location: location, limit: 10).url(baseURL: ROOT)
        
        return Deferred {
            Future() { promise in
                self.httpClient.get(url: url) { response in
                    switch response {
                    case let .success(data):
                        if let root = try? JSONDecoder().decode(RootItem.self, from: data) {
                            promise(.success(root.businesses ?? []))
                        } else {
                            promise(.failure(.invalidData))
                        }
                    case .failure:
                        promise(.failure(.connectionError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    func fetchBusinessReviews(with id: String) -> AnyPublisher<[Review], Error> {
        let url = Endpoint.reviews(id: id).url(baseURL: ROOT)
        
        return Deferred {
            Future() { promise in
                self.httpClient.get(url: url) { response in
                    switch response {
                    case let .success(data):
                        if let root = try? JSONDecoder().decode(RootItem.self, from: data) {
                            promise(.success(root.reviews ?? []))
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
