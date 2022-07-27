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
    
    func test_fetchBusinesses_responseNoItemsOn200HTTPReponseWithEmptyJSONList() {
        let (sut, loader) = makeSUT()
        let emptyJSONList = "{\"businesses\": []}".data(using: .utf8)!

        expect(sut, toCompleteWith: .success([])) {
            loader.complete(withStatusCode: 200, data: emptyJSONList)
        }
    }
    
    func test_fetchBusinesses_responseListItemOn200HTTPReponseWithJSONList() {
        let (sut, loader) = makeSUT()
        let item1 = BusinessModel(id: "id1", name: "a name", rating: 0, imageURL: "http://any-url.com", displayAddress: ["a"], categories: ["category1"], isLiked: false)
        
        let itemJSON1: [String: Any] = [
            "id": item1.id,
            "name": item1.name,
            "image_url": item1.imageURL,
            "rating": item1.rating,
            "categories": [
                [
                    "title": "category1"
                ],
            ],
            "location": [
                "display_address": item1.displayAddress
            ]
        ]
        
        let item2 = BusinessModel(id: "id2", name: "other name", rating: 0, imageURL: "http://other-any-url.com", displayAddress: ["b"], categories: ["category2"], isLiked: false)
        
        let itemJSON2: [String: Any] = [
            "id": item2.id,
            "name": item2.name,
            "image_url": item2.imageURL,
            "rating": item2.rating,
            "categories": [
                [
                    "title": "category2"
                ],
            ],
            "location": [
                "display_address": item2.displayAddress
            ]
        ]
        
        let items = [item1, item2]
        
        let jsonList = ["businesses": [itemJSON1, itemJSON2]]

        expect(sut, toCompleteWith: .success(items)) {
            let json = try! JSONSerialization.data(withJSONObject: jsonList, options: .prettyPrinted)
            loader.complete(withStatusCode: 200, data: json)
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
