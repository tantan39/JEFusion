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
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_retrieveBusinessLike_deliversFoundValues() {
        let sut = makeSUT()
        let item1 = LikeModel(businessId: "id", isLiked: false)
        let item2 = LikeModel(businessId: "id1", isLiked: false)
        
        sut.insertLikeModel(item1)
            .sink(receiveCompletion: { _ in }) { _ in }
            .store(in: &cancellables)

        sut.insertLikeModel(item2)
            .sink(receiveCompletion: { _ in }) { _ in }
            .store(in: &cancellables)
        
        expect(sut, toRetrieve: .success([item1, item2]))
        
    }
    
    func test_retrieveBusinessLike_hasNoSideEffectsDeliversFoundValues() {
        let sut = makeSUT()
        let item1 = LikeModel(businessId: "id", isLiked: false)
        let item2 = LikeModel(businessId: "id1", isLiked: false)
        
        sut.insertLikeModel(item1)
            .sink(receiveCompletion: { _ in }) { _ in }
            .store(in: &cancellables)

        sut.insertLikeModel(item2)
            .sink(receiveCompletion: { _ in }) { _ in }
            .store(in: &cancellables)
        
        expect(sut, toRetrieve: .success([item1, item2]))
        expect(sut, toRetrieve: .success([item1, item2]))
        
    }
    
    func test_insertLikeModel_deliversNoError() {
        let sut = makeSUT()
        let item1 = LikeModel(businessId: "id", isLiked: false)
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for loading")
        sut.insertLikeModel(item1)
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    receivedError = error
                    exp.fulfill()
                default:
                    break
                }
            }) { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(receivedError)
    }
    
    func test_updateLikeModel_deliversNoError() {
        let sut = makeSUT()
        let item1 = LikeModel(businessId: "id1", isLiked: false)
        var receivedError: Error?
        
        sut.insertLikeModel(item1)
            .sink(receiveCompletion: { _ in }) { _ in }
            .store(in: &cancellables)
        
        let exp = expectation(description: "Wait for loading")
        sut.updateLikeModel("id1", isLiked: true)
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    receivedError = error
                    exp.fulfill()
                default:
                    break
                }
            }) { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        expect(sut, toRetrieve: .success([LikeModel(businessId: "id1", isLiked: true)]))
        XCTAssertNil(receivedError)
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> BusinessStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataBusinessStore(storeURL: storeURL)
        return sut
    }
    
    private func expect(_ sut: BusinessStore, toRetrieve expectedResult: Result<[LikeModel], Error>, file: StaticString = #filePath, line: UInt = #line) {
        var retrievedResult: Result<[LikeModel], Error>?
        
        let exp = expectation(description: "Wait for loading")
        
        sut.retrieveBusinessLike()
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    retrievedResult = .failure(error)
                default:
                    break
                }
            }, receiveValue: { items in
                retrievedResult = .success(items)
                exp.fulfill()
            })
            .store(in: &cancellables)
            
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrievedResult, expectedResult, file: file, line: line)
    }
}
