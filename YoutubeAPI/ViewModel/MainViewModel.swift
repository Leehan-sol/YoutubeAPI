//
//  MainViewModel.swift
//  YoutubeAPI
//
//  Created by hansol on 2024/07/11.
//

import UIKit

protocol VMProtocol {
    var datas: [YoutubeModel] { get set }
    var onCompleted: ([YoutubeModel]?) -> Void { get set }
    var totalDataCount: Int { get }
    
    func setData(page: Int, maxResults: Int)
    func makeImage(at index: Int, completion: @escaping (UIImage?) -> Void)
}


class MainViewModel: VMProtocol {
    
    private let manager: APIProtocol
    
    init(manager: APIProtocol) {
        self.manager = manager
    }
    
    var datas: [YoutubeModel] = [] {
        didSet {
            onCompleted(datas)
        }
    }
    
    var totalDataCount: Int {
        return manager.getTotalResult()
    }
    
    var onCompleted: ([YoutubeModel]?) -> Void = { _ in }
    
    func setData(page: Int, maxResults: Int)  {
        manager.fetchURL(page: page, maxResults: maxResults) { [weak self] result in
            switch result {
            case .success(let newData):
                self?.datas.append(contentsOf: newData)
            case .failure(let error):
                switch error {
                case .dataError:
                    print("데이터 에러")
                case .networkingError:
                    print("네트워킹 에러")
                case .parseError:
                    print("파싱 에러")
                case .invalidRequest:
                    print("클라이언트 요청 에러")
                case .serverError:
                    print("서버 에러")
                case .unknownError:
                    print("알 수 없는 에러")
                }
            }
        }
    }
    
    func makeImage(at index: Int, completion: @escaping (UIImage?) -> Void) {
        guard index >= 0, index < datas.count else {
            completion(nil)
            return
        }
        let thumbnailURL = datas[index].imageURL
        fetchImage(from: thumbnailURL) { image in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func fetchImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error)")
                completion(nil)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
    
}

