//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

protocol NetworkRouting {
    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkClient: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    func fetch(request: URLRequest, handler: @escaping (Result<Data, any Error>) -> Void) {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let response,
                   let data,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        if statusCode < 200 || statusCode >= 300 {
                            fulfillCompletionOnTheMainThread(.failure(NetworkClient.httpStatusCode(statusCode)))
                            print("Error: HTTP Status Code \(statusCode)")
                        } else {
                            fulfillCompletionOnTheMainThread(.success(data))
                        }
                } else if let error {
                    fulfillCompletionOnTheMainThread(.failure(NetworkClient.urlRequestError(error)))
                    print("Error: URL Request error \(error)")
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkClient.urlSessionError))
                    print("Error: URL Session Error")
                }
            }
        )
        task.resume()
    }
}
