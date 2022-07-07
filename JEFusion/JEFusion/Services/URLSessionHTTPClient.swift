//
//  URLSessionHTTPClient.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import JECore

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession = .shared
        
    func get(url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.addValue("Bearer \(API_Key)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { data, response, error in
            completion(Result {
              if let error = error {
                throw error
              } else if let data = data {
                return data
              } else {
                  throw Error.connectionError
              }
            })
        }
        .resume()
    }
}
