//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

protocol NetworkRouting {
    func performRequestAndDecode<T: Decodable>(
        request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask?
    func performRequest(
        request: URLRequest,
        handler: @escaping (Result<Data, any Error>) -> Void
    ) -> URLSessionDataTask?
}

struct NetworkClient: NetworkRouting {
    
    // MARK: - Errors
    
    private enum NetworkClient: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    // MARK: - Private Properties
    
    private let oAuth2Service: OAuth2Service
    private let decoder = JSONDecoder()
    
    // MARK: Initializers
    
    init(oAuth2Service: OAuth2Service = OAuth2Service.shared) {
        self.oAuth2Service = oAuth2Service
    }
    
    // MARK: - Internal Methods
    
    func performRequestAndDecode<T: Decodable>(
        request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask? {
        
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = performRequest(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    decoder.dateDecodingStrategy = .iso8601
                    let response = try decoder.decode(T.self, from: data)
                    fulfillCompletionOnTheMainThread(.success(response))
                } catch {
                    assertionFailure("Error: decoding error \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            case .failure(let error):
                assertionFailure("Error: \(error)")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        return task
    }
    
    func performRequest(request: URLRequest, handler: @escaping (Result<Data, any Error>) -> Void) -> URLSessionDataTask? {
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let response,
                   let data,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if statusCode < 200 || statusCode >= 300 {
                        assertionFailure("Error: HTTP Status Code \(statusCode)")
                        handler(.failure(NetworkClient.httpStatusCode(statusCode)))
                    } else {
                        handler(.success(data))
                    }
                } else if let error {
                    assertionFailure("Error: URL Request error \(error)")
                    handler(.failure(NetworkClient.urlRequestError(error)))
                } else {
                    assertionFailure("Error: URL Session Error")
                    handler(.failure(NetworkClient.urlSessionError))
                }
            }
        }
        task.resume()
        return task
    }
}
