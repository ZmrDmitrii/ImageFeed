//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

protocol NetworkRouting {
    func performRequest(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkClient: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    private var oAuth2Service: OAuth2Service = OAuth2Service.shared
    
    init(oAuth2Service: OAuth2Service = OAuth2Service.shared) {
        self.oAuth2Service = oAuth2Service
    }
    
    func performRequest(request: URLRequest, handler: @escaping (Result<Data, any Error>) -> Void) {
//        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async {
//                handler(result)
//            }
//        }
        let task: URLSessionDataTask = URLSession.shared.dataTask(
            with: request,
            completionHandler: { [weak oAuth2Service] data, response, error in
                DispatchQueue.main.async {
                    if let response,
                       let data,
                       let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            if statusCode < 200 || statusCode >= 300 {
                                handler(.failure(NetworkClient.httpStatusCode(statusCode)))
                                print("Error: HTTP Status Code \(statusCode)")
                            } else {
                                handler(.success(data))
                            }
                    } else if let error {
                        handler(.failure(NetworkClient.urlRequestError(error)))
                        print("Error: URL Request error \(error)")
                    } else {
                        handler(.failure(NetworkClient.urlSessionError))
                        print("Error: URL Session Error")
                    }
                    oAuth2Service?.task = nil
                    oAuth2Service?.lastCode = nil
                }
            }
        )
        oAuth2Service.task = task
        task.resume()
    }
}
