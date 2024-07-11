//
//  MainViewController.swift
//  YoutubeAPI
//
//  Created by hansol on 2024/07/11.
//

import UIKit

class MainViewController: UIViewController {
    private let mainView = MainView()
    private var currentPage = 0
    private var viewModel: VMProtocol
    
    init(viewModel: VMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCV()
        loadPage()
        setBinding()
    }
    
    func setCV() {
        mainView.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
    }
    
    func loadPage() {
        currentPage += 1
        viewModel.setData(page: currentPage, maxResults: Constants.maxResults)
    }
    
    func setBinding() {
        self.viewModel.onCompleted = { [weak self] _ in
            DispatchQueue.main.async {
                self?.mainView.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let currentRow = indexPath.row
        
        if currentRow < viewModel.totalDataCount
            && (currentRow % Constants.maxResults) == Constants.maxResults - 5
            && (currentRow / Constants.maxResults) == (currentPage - 1) {
            loadPage()
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    // 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        let cellHeight = (collectionView.frame.height - 8) / 4
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}


// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let row = viewModel.datas[indexPath.row]
        
        cell.titleLabel.text = row.title
        cell.descriptionLabel.text = row.description
        
        viewModel.makeImage(at: indexPath.row) { image in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedVideo = viewModel.datas[indexPath.row].imageURL
        
        if let videoId = selectedVideo.makeVideoId() {
            let detailView = DetailViewController(videoId: videoId) // lJxqVf6IP6E
            navigationController?.pushViewController(detailView, animated: true)
        } else {
            print("video가 없습니다")
        }
    }
    
    
    
}


