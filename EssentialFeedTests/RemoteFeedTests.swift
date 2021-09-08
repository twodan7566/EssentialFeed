//
//  RemoteFeedTests.swift
//  EssentialFeedTests
//
//  Created by Ta Cheng on 2021/7/5.
//

import XCTest
@testable import EssentialFeed


class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!
        _ = RemoteFeedLoader(url: url, client:client)
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
     
    func test_load_requestsDataFromURL(){
        let url = URL(string: "https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestURLs,[url])
        
    }
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestURLs,[url,url])
        
    }
    
//    func test_load_deliversErrorOnClientError(){
//        let (sut,client) = makeSUT()
//
//        var capturedError = [RemoteFeedLoader.Error]()
//        sut.load{  capturedError.append($0) }
//
//        let clientError = NSError(domain: "Test", code: 0)
//        client.complete(with:clientError)
//        XCTAssertEqual(capturedError, [.connectivity])
//
//    }
    
//    func test_load_deliversErrorOnNon200HTTPResponse(){
//        let (sut,client) = makeSUT()
//
//
//        let sample = [199,201,300,400,500]
//
//        sample.enumerated().forEach { index,code in
//            var capturedErrors = [RemoteFeedLoader.Error]()
//            sut.load{  capturedErrors.append($0) }
//            client.complete(withStatusCode: code,at: index)
//            XCTAssertEqual(capturedErrors, [.invalidData])
//        }
//
//
//
//    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson(){
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJson = Data("Invalid Json".utf8)
            client.complete(withStatusCode: 200,data:invalidJson)
        }
    }
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList(){
        let (sut,client) = makeSUT()
        var captureResults = [RemoteFeedLoader.Result]()
        sut.load{captureResults.append($0)}
        
        let emptyListJSON = Data(bytes:"{\"items\":[]}".utf8)
        client.complete(withStatusCode: 200, data: emptyListJSON)
        
        XCTAssertEqual(captureResults, [.success([])])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url:URL = URL(string: "https://a-url.com")!)-> (sut:RemoteFeedLoader,client:HTTPClientSpy){
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        
        return (sut,client)
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompleteWithError error:RemoteFeedLoader.Error,when action:()->Void,file:StaticString = #filePath,line:Int = #line){
        var captureResults = [RemoteFeedLoader.Result]()
        sut.load{ captureResults.append($0) }
        action()
        
        XCTAssertEqual(captureResults,[.failure(error)],file: file,line:UInt(line))
        
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURLs:[URL]{
            return messages.map{$0.url}
        }
        
        private var messages = [(url:URL,completion: (HTTPClientResult)->Void)]()
        
        func get(from url:URL,completion: @escaping (HTTPClientResult)->Void){
            messages.append((url,completion))
        }
        
        func complete(with error:Error,at index:Int = 0){
            messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code:Int,data:Data = Data(),at index:Int = 0){
            let response = HTTPURLResponse(url: requestURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data,response))
        }
        
    }
}
