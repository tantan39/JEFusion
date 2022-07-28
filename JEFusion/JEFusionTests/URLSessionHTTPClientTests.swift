//
//  URLSessionHTTPClientTests.swift
//  JEFusionTests
//
//  Created by Tan Tan on 7/27/22.
//

import Foundation
import XCTest
@testable import JEFusion

class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performGETrequestWithURL() {
        let url = URL(string: "http://any-url.com")!
                
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observerRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(url: url, completion: { _ in })
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let error = NSError(domain: "any error", code: 1)
        let receiveError = resultsForError(data: nil, response: nil, error: error)
        if let receiveError = receiveError as NSError? {
            XCTAssertEqual(receiveError.domain, error.domain)
            XCTAssertEqual(receiveError.code, error.code)
        }
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        let error = resultsForError(data: nil, response: nil, error: nil)
        
        XCTAssertNotNil(error)
    }
    
    func test_getFromURL_succeedsOnHTTPResponseWithData() {
        let url = URL(string: "http://any-url.com")!
        let anyData = "any data".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolStub.stub(data: anyData, response: response, error: nil)
        
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request")
        
        sut.get(url: url, completion: { result in
            switch result {
            case .success((let receiveData, let receiveResponse)):
                XCTAssertEqual(receiveData, anyData)
                XCTAssertEqual(receiveResponse.url, response.url)
                XCTAssertEqual(receiveResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected failure, got \(result) instead")

            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func resultsForError(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let url = URL(string: "http://any-url.com")!
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request")
        var receiveError: Error?
        
        sut.get(url: url, completion: { result in
            switch result {
            case let .failure(error):
                receiveError = error
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return receiveError
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observerRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
}
