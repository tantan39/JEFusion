//
//  APIServiceTests.swift
//  JEFusionTests
//
//  Created by Tan Tan on 7/25/22.
//

import XCTest
import JECore
import Combine

@testable import JEFusion

class APIServiceTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    func test_fetchBusinesses_failingDeliverConnectionError() {
        let (sut, loader) = makeSUT()
        let connectionError = Error.connectionError
        
        sut.fetchBusinesses(by: "a location")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, connectionError)
                case .finished:
                    assertionFailure("finished")
                }
            }, receiveValue: { items in
                XCTAssertTrue(items.count > 0)
            }).store(in: &cancellables)
        
        loader.complete(with: connectionError)
        
    }
    
    private func makeSUT() -> (APIService, HTTPClientStub) {
        let loader = HTTPClientStub()
        let sut = APIService(httpClient: loader)
        return (sut, loader)
    }
    
    private class HTTPClientStub: HTTPClient {
        var messages: [(Result<Data, Swift.Error>) -> Void] = []
        
        func get(url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            messages.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index](.failure(error))
        }
    }
}
