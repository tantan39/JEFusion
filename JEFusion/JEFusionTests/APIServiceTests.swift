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
    
    func test_fetchBusinesses_responseNon200StatusCode() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            loader.complete(withStatusCode: 404)
        }
    }
    
    func test_fetchBusinesses_responseErrorOn200StatusCodeWithInvalidJSON() {
        let (sut, loader) = makeSUT()
        let invalidJSON = "invalid JSON".data(using: .utf8)!

        expect(sut, toCompleteWith: .failure(.invalidData)) {
            loader.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
//    func test_fetchBusinesses_responseNoItemsOn200HTTPReponseWithEmptyJSONList() {
//        let (sut, loader) = makeSUT()
//        let emptyJSONList = "{\"businesses\": []}".data(using: .utf8)!
//
//        expect(sut, toCompleteWith: .success([])) {
//            loader.complete(withStatusCode: 200, data: emptyJSONList)
//        }
//    }
    
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
                    break
                }
            }, receiveValue: { captureResults.append(.success($0)) })
            .store(in: &cancellables)
        
        action()
        
        XCTAssertEqual(captureResults, [result])
    }
    
    private class HTTPClientStub: HTTPClient {
        var messages: [(Result<(Data, HTTPURLResponse), Swift.Error>) -> Void] = []
        var requestURLs: [URL] = []
        
        func get(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Swift.Error>) -> Void) {
            requestURLs.append(url)
            messages.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index](.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = .init(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index](.success((data, response)))
        }
    }
}
