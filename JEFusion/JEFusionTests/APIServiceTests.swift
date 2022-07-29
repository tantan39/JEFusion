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
        let item1 = makeModel(id: "id", name: "a name", rating: 0, imageURL: "http://any-url.com", displayAddress: ["a"], categories: "category")
        
        let item2 = makeModel(id: "id2", name: "other name", rating: 0, imageURL: "http://other-any-url.com", displayAddress: ["b"], categories: "category2")
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeJSONItems([item1.json, item2.json])
            loader.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_fetchBusinessReviews_failingDeliverConnectionError() {
        let (sut, loader) = makeSUT()
        
        expectFetchBusinessReviews(sut, toCompleteWith: .failure(.connectionError)) {
            loader.complete(with: .connectionError)
        }
    }
    
    func test_fetchBusinessReviews_responseNon200StatusCode() {
        let (sut, loader) = makeSUT()

        expectFetchBusinessReviews(sut, toCompleteWith: .failure(.invalidData)) {
            loader.complete(withStatusCode: 404)
        }
    }

    func test_fetchBusinessReviews_responseErrorOn200StatusCodeWithInvalidJSON() {
        let (sut, loader) = makeSUT()
        let invalidJSON = "invalid JSON".data(using: .utf8)!

        expectFetchBusinessReviews(sut, toCompleteWith: .failure(.invalidData)) {
            loader.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    func test_fetchBusinessReviews_responseNoItemsOn200HTTPReponseWithEmptyJSONList() {
        let (sut, loader) = makeSUT()
        let emptyJSONList = "{\"businesses\": []}".data(using: .utf8)!

        expectFetchBusinessReviews(sut, toCompleteWith: .success([])) {
            loader.complete(withStatusCode: 200, data: emptyJSONList)
        }
    }

    func test_fetchBusinessReviews_responseListItemOn200HTTPReponseWithJSONList() {
        let (sut, loader) = makeSUT()

        let item1 = Review(id: "id1", text: "review1", user: Review.User(id: "user1", name: "name"))
        let itemJSON1: [String: Any] = [
            "id": item1.id,
            "text": item1.text,
            "user": [
                "id": item1.user.id,
                "name": item1.user.name
            ]
        ]
        
        let items = [item1]
        let json = ["reviews": [itemJSON1]]
        expectFetchBusinessReviews(sut, toCompleteWith: .success(items)) {
            let data = try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            loader.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliverReultAfterInstanceHasBeenDellocated() {
        let loader = HTTPClientStub()
        var sut: APIService? = APIService(httpClient: loader)
        var captureResults: [Result<[BusinessModel], Error>] = []
        
        sut?.fetchBusinesses(by: "location")
            .sink(receiveCompletion: { _ in }, receiveValue: { captureResults.append(.success($0)) })
            .store(in: &cancellables)
        
        sut = nil
        
        loader.complete(withStatusCode: 200, data: makeJSONItems([]))
        
        XCTAssertEqual(captureResults, [])
    }
    
    func test_fetchBusinessReviews_doesNotDeliverReultAfterInstanceHasBeenDellocated() {
        let loader = HTTPClientStub()
        var sut: APIService? = APIService(httpClient: loader)
        var captureResults: [Result<[Review], Error>] = []
        
        sut?.fetchBusinessReviews(with: "id")
            .sink(receiveCompletion: { _ in }, receiveValue: { captureResults.append(.success($0)) })
            .store(in: &cancellables)
        
        sut = nil
        let json = ["reviews": []]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        loader.complete(withStatusCode: 200, data: data)
        
        XCTAssertEqual(captureResults, [])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (APIService, HTTPClientStub) {
        let loader = HTTPClientStub()
        let sut = APIService(httpClient: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dellocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func makeModel(id: String, name: String, rating: Double, imageURL: String, displayAddress: [String], categories: String) -> (model: BusinessModel, json: [String: Any]) {
        let model = BusinessModel(id: "id1", name: "a name", rating: 0, imageURL: "http://any-url.com", displayAddress: ["a"], categories: [categories], isLiked: false)
        
        let json: [String: Any] = [
            "id": model.id,
            "name": model.name,
            "image_url": model.imageURL,
            "rating": model.rating,
            "categories": [
                [
                    "title": categories
                ],
            ],
            "location": [
                "display_address": model.displayAddress
            ]
        ]
        
        return (model, json)
    }
    
    private func makeJSONItems(_ items: [[String: Any]]) -> Data {
        let json = ["businesses": items]
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
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
    
    private func expectFetchBusinessReviews(_ sut: APIService, toCompleteWith result: Result<[Review], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var captureResults: [Result<[Review], Error>] = []
        
        sut.fetchBusinessReviews(with: "id")
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
