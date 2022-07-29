//
//  CoreDataBusinessStoreTests.swift
//  JEFusionTests
//
//  Created by Tan Tan on 7/28/22.
//

import XCTest
import JECore
import Combine
@testable import JEFusion

class CoreDataBusinessStoreTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func test_retrieveBusinessLike_deliversEmpty() {
        let sut = makeSUT()
        var result: Result<[LikeModel], Error>?
        let exp = expectation(description: "Wait for loading")
        
        sut.retrieveBusinessLike()
            .sink(receiveCompletion: { _ in }, receiveValue: { items in
                result = .success(items)
                exp.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(result, .success([]))
        
    }
    
    func test_retrieveBusinessLike_deliversFoundValues() {
        let sut = makeSUT()
        var result: Result<[LikeModel], Error>?
        let exp = expectation(description: "Wait for loading")
        let item1 = LikeModel(businessId: "id", isLiked: false)
        let item2 = LikeModel(businessId: "id1", isLiked: false)
        
        sut.insertLikeModel(item1)
            .sink(receiveCompletion: { _ in }) { _ in }
            .store(in: &cancellables)

        sut.insertLikeModel(item2)
            .sink(receiveCompletion: { _ in }) { _ in }
            .store(in: &cancellables)
        
        sut.retrieveBusinessLike()
            .sink(receiveCompletion: { _ in }, receiveValue: { items in
                result = .success(items)
                exp.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(result, .success([item1, item2]))
        
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> BusinessStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataBusinessStore(storeURL: storeURL)
        return sut
    }
}
