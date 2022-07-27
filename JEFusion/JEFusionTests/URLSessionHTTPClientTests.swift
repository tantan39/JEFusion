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
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        session.stub(request: url, task: task)
        sut.get(url: url, completion: { _ in })
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    private class URLSessionSpy: URLSession {
        var requestURLs: [URL] = []
        private var stubs: [URL: URLSessionDataTaskSpy] = [:]
        
        func stub(request: URL, task: URLSessionDataTaskSpy) {
            stubs[request] = task
        }
        
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            requestURLs.append(request.url!)
            return stubs[request.url!] ?? FakeURLSessionDataTask()
            
        }
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
