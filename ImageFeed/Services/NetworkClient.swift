//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

protocol NetworkRouting {
    func performRequestAndDecode<T: Decodable>(
        serviceType: ServiceType,
        request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

struct NetworkClient: NetworkRouting {
    
    // MARK: - Errors
    private enum NetworkClient: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    // MARK: - Private Properties
    private var oAuth2Service: OAuth2Service
    
    // MARK: Initializers
    init(oAuth2Service: OAuth2Service = OAuth2Service.shared) {
        self.oAuth2Service = oAuth2Service
    }
    
    // MARK: - Public Methods
    func performRequestAndDecode<T: Decodable>(
        serviceType: ServiceType,
        request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        performRequest(serviceType: serviceType, request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    fulfillCompletionOnTheMainThread(.success(response))
                } catch {
                    assertionFailure("Error: decoding error \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    print("Error: decoding error \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            case .failure(let error):
                assertionFailure("Error: \(error)")
                print("Error: \(error)")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
    }
    
    
    // MARK: - Private Methods
    private func performRequest(serviceType: ServiceType, request: URLRequest, handler: @escaping (Result<Data, any Error>) -> Void) {
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { [weak oAuth2Service] data, response, error in
            DispatchQueue.main.async {
                if let response,
                   let data,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if statusCode < 200 || statusCode >= 300 {
                        assertionFailure("Error: HTTP Status Code \(statusCode)")
                        print("Error: HTTP Status Code \(statusCode)")
                        handler(.failure(NetworkClient.httpStatusCode(statusCode)))
                    } else {
                        handler(.success(data))
                    }
                } else if let error {
                    assertionFailure("Error: URL Request error \(error)")
                    print("Error: URL Request error \(error)")
                    handler(.failure(NetworkClient.urlRequestError(error)))
                } else {
                    assertionFailure("Error: URL Session Error")
                    print("Error: URL Session Error")
                    handler(.failure(NetworkClient.urlSessionError))
                }
                handleRaceCondition(serviceType: serviceType, oAuth2Service: oAuth2Service)
            }
        }
        
        if serviceType == ServiceType.oauth2 {
            oAuth2Service.task = task
        } else {
            // TODO: обработка для Profile, если нужна
        }
        
        task.resume()
    }
    
    private func handleRaceCondition(serviceType: ServiceType, oAuth2Service: OAuth2Service?) {
        switch serviceType {
        case .oauth2:
            oAuth2Service?.task = nil
            oAuth2Service?.lastCode = nil
        case .profile:
            //TODO: обработка race condition для profile, если нужна
            break
        }
    }
}
