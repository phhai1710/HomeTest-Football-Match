//
//  URLSessionService.swift
//  
//
//  Created by Hai Pham on 28/02/2023.
//

import Foundation
import Combine

/// The service class of URLSession
final class URLSessionService {
    // TODO: Move URL to Application layer
    static let shared = URLSessionService(baseURLString: "https://jmde6xvjr4.execute-api.us-east-1.amazonaws.com")
    
    let urlSession: URLSession
    let baseURLString: String
    
    /**
     - Parameters:
        - urlSession: The `URLSession` instance to use for network requests. Default value is `URLSession.shared`.
        - baseURLString: The base URL string to use for network requests. This parameter is required.
     */
    init(urlSession: URLSession = .shared, baseURLString: String) {
        self.urlSession = urlSession
        self.baseURLString = baseURLString
    }
    
    /**
     Returns a `URLSession.DataTaskPublisher` for the specified endpoint.

     - Parameters:
        - endpoint: The endpoint to use for the network request.

     - Returns: A `URLSession.DataTaskPublisher` for the specified endpoint.
     */
    func dataTaskPublisher(for endpoint: String) -> URLSession.DataTaskPublisher {
        let url = URL(string: baseURLString.appending(endpoint))!
        let request = URLRequest(url: url)
        return urlSession.dataTaskPublisher(for: request)
    }
}
