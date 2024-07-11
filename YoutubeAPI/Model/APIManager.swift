//
//  APIManager.swift
//  YoutubeAPI
//
//  Created by hansol on 2024/07/11.
//

import Foundation

protocol APIProtocol {
    func getTotalResult() -> Int
    func fetchURL(page: Int, maxResults: Int, completion: @escaping (Result<[YoutubeModel], NetworkError>) -> Void)
}

enum NetworkError: Error {
    case networkingError
    case dataError
    case parseError
    case invalidRequest
    case serverError
    case unknownError
}

class APIManager: APIProtocol {
    private let baseURL = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&type=video&key=\(Secret.apiKey)"
    var totalResult: Int = 0
    
    func getTotalResult() -> Int {
        return totalResult
    }
    
    // 1. URL 만들기
    func fetchURL(page: Int, maxResults: Int, completion: @escaping (Result<[YoutubeModel], NetworkError>) -> Void) {
        let urlString = "\(baseURL)&page=\(page)&maxResults=\(maxResults)"
        fetchData(url: urlString, completion: completion)
    }
    
    func fetchData(url: String, completion: @escaping (Result<[YoutubeModel], NetworkError>) -> Void) {
        // 2. URL 객체 생성
        guard let url = URL(string: url) else {
            completion(.failure(.networkingError))
            return
        }
        
        // 3. URL 세션 생성
        let session = URLSession(configuration: .default)
        
        // 4. 데이터테스크 생성
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.dataError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.dataError))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                // 5. 데이터 파싱
                if let data = data, let parseData = self.parseJson(data) {
                    completion(.success(parseData))
                } else {
                    completion(.failure(.parseError))
                }
            case 400..<500:
                completion(.failure(.invalidRequest))
            case 500..<600:
                completion(.failure(.serverError))
            default:
                completion(.failure(.unknownError))
            }
        }
        dataTask.resume()
    }
    
    
    func parseJson(_ parseData: Data) -> ([YoutubeModel]?)  {
        let decoder = JSONDecoder()
        do {
            let youtubeData = try decoder.decode(YoutubeData.self, from: parseData)
            let totalResult = youtubeData.pageInfo.totalResults
            
            var models: [YoutubeModel] = []
            for item in youtubeData.items {
                let snippet = item.snippet
                let thumbnail = snippet.thumbnails.high.url
                let title = snippet.title
                let description = snippet.description
                
                let model = YoutubeModel(imageURL: thumbnail, title: title, description: description)
                models.append(model)
            }
            self.totalResult = totalResult
            return models
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    
}

