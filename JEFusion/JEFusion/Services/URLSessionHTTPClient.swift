//
//  URLSessionHTTPClient.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import JECore

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
        
    func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Swift.Error>) -> Void) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.addValue("Bearer \(API_Key)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { data, response, error in
            completion(Result {
              if let error = error {
                throw error
              } else if let data = data, let response = response as? HTTPURLResponse {
                return (data, response)
              } else {
                  throw Error.connectionError
              }
            })
        }
        .resume()
    }
}
