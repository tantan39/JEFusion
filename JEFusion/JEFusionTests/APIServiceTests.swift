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
    
    func test_fetchBusinesses_failingDeliverConnectionError() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectionError)) {
            loader.complete(with: .connectionError)
        }
    }
    
    func test_fetchBusinesses_successDeliverEmptyJSON() {
        let (sut, loader) = makeSUT()
        let invalidJSON = "invalid JSON".data(using: .utf8)!

        expect(sut, toCompleteWith: .failure(.invalidData)) {
            loader.complete(with: invalidJSON)
        }
    }
    
    private func makeSUT() -> (APIService, HTTPClientStub) {
        let loader = HTTPClientStub()
        let sut = APIService(httpClient: loader)
        return (sut, loader)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func expect(_ sut: APIService, toCompleteWith result: Result<[BusinessModel], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var captureResults: [Result<[BusinessModel], Error>] = []
        
        sut.fetchBusinesses(by: "a location")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    captureResults.append(.failure(error))
                case .finished:
                    assertionFailure("finished")
                }
            }, receiveValue: { captureResults.append(.success($0)) })
            .store(in: &cancellables)
        
        action()
        
        XCTAssertEqual(captureResults, [result])
    }
    
    private class HTTPClientStub: HTTPClient {
        var messages: [(Result<Data, Swift.Error>) -> Void] = []
        
        func get(url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            messages.append(completion)
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index](.success(data))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index](.failure(error))
        }
    }
}
