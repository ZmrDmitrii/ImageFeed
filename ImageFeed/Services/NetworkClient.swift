//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

protocol NetworkRouting {
    func performRequest(serviceType: ServiceType, request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkClient: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    private var oAuth2Service: OAuth2Service
    
    init(oAuth2Service: OAuth2Service = OAuth2Service.shared) {
        self.oAuth2Service = oAuth2Service
    }
    
    func performRequest(serviceType: ServiceType, request: URLRequest, handler: @escaping (Result<Data, any Error>) -> Void) {
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { [weak oAuth2Service] data, response, error in
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
