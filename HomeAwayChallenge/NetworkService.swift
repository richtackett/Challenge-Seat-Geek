//
//  NetworkService.swift
//  HomeAwayChallenge
//
//  Created by RICHARD TACKETT on 7/31/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import Foundation

enum Result{
    case success(SearchResponse)
    case failure(NSError)
}

final class NetworkService {
    fileprivate let clientID = "ODM0MTkwMnwxNTAxNTIyNTEyLjk2"
    fileprivate let session = URLSession.shared
    fileprivate let responseParser = ResponseParser()
    
    func sendRequest(query: String, page: Int, completion: @escaping ((Result) -> Void)) {
        guard let urlRequest = _makeRequest(query: query, page: page) else {
            let error = NSError(domain: "HomeAwayChallenge", code: 100, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        let task = session.dataTask(with: urlRequest) {[weak self] (data, response, error) in
            self?._handleRespone(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
}

fileprivate extension NetworkService {
    func _makeRequest(query: String, page: Int) -> URLRequest? {
        guard let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        let path = "https://api.seatgeek.com/2/events?client_id=\(clientID)&q=\(queryString)&page=\(page)"
        guard let url = URL(string: path) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
    
    
    func _handleRespone(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ((Result) -> Void)) {
        if let error = error {
            completion(.failure(error as NSError))
        } else {
            guard let response = response as? HTTPURLResponse else {
                let error = NSError(domain: "HomeAwayChallenge", code: 102, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            var jsonDictionary =  [String: Any]()
            if let data = data {
                let JSON = try? JSONSerialization.jsonObject(with: data)
                
                if let dict = JSON as? [String: Any] {
                    jsonDictionary = dict
                }
            }
            
            if let searchRespone = responseParser.parse(JSON: jsonDictionary),
                response.statusCode < 400 {
                completion(.success(searchRespone))
            } else {
                let error = NSError(domain: "HomeAwayChallenge", code: 102, userInfo: nil)
                completion(.failure(error))
            }
        }
    }
}
