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
        URLProtocolStub.startInterceptingRequests()
    }
    override class func tearDown() {
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
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)

        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request")
        
        sut.get(url: url, completion: { result in
            switch result {
            case let .failure(receiveError as NSError):
                XCTAssertEqual(receiveError.domain, error.domain)
                XCTAssertEqual(receiveError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        let url = URL(string: "http://any-url.com")!

        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request")
        
        sut.get(url: url, completion: { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failure, got \(result) instead")

            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
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
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
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
        
        override func stopLoading() { }
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
