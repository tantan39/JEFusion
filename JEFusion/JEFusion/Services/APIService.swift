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

public final class APIService: BusinessLoader {
    
    private var httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    private struct RootItem: Decodable {
        let businesses: [BusinessModel]?
        let reviews: [Review]?
    }
    
    public func fetchBusinesses(by location: String) -> AnyPublisher<[BusinessModel], Error> {
        let url = Endpoint.getBusiness(location: location, limit: 10).url(baseURL: ROOT)

        return Deferred {
            Future() { promise in
                self.httpClient.get(url: url) { [weak self] response in
                    guard self != nil else { return }
                    switch response {
                    case .success((let data, let httpResponse)):
                        if let root = try? JSONDecoder().decode(RootItem.self, from: data), httpResponse.statusCode == 200 {
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
    
    public func fetchBusinessReviews(with id: String) -> AnyPublisher<[Review], Error> {
        let url = Endpoint.reviews(id: id).url(baseURL: ROOT)
        
        return Deferred {
            Future() { promise in
                self.httpClient.get(url: url) { [weak self] response in
                    guard self != nil else { return }
                    switch response {
                    case .success((let data, _)):
                        if let root = try? JSONDecoder().decode(RootItem.self, from: data) {
                            promise(.success(root.reviews ?? []))
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
}
