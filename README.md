## ⚙️ Youtube API
URLSession 클래스를 사용해 Youtube API와 네트워킹을 구현하고 무한스크롤을 처리해 API 사용과 네트워킹에 대한 이해도를 높였습니다.

<br/>

<div align="center">
  <img width="200" height="400" alt="image" src="https://github.com/Leehan-sol/YoutubeAPI/assets/139109343/f1706c87-d885-4091-ad8c-754fd324c667">
</div>

<br/>

## 🛠️ Workflow

1. **Model 정의 및 Error enum 정의** <br/>
네트워킹 성공 시 Json데이터를 디코딩 하기 위한 모델과 디코딩 된 데이터를 담을 모델, error를 정의하기 위한 열거형을 만들어줍니다.
```swift
// YoutubeModel
struct YoutubeModel {
    var imageURL: String
    var title: String
    var description: String
}

// YoutubeDataModel
struct YoutubeData: Codable {
    let pageInfo: PageInfo
    let items: [Item]
}

struct PageInfo: Codable {
    let totalResults: Int
}

struct Item: Codable {
    let snippet: Snippet
}

struct Snippet: Codable {
    let title, description: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let high: Default
}

struct Default: Codable {
    let url: String
}

// NetworkError
enum NetworkError: Error {
    case networkingError
    case dataError
    case parseError
    case invalidRequest
    case serverError
    case unknownError
}
```
2. **네트워킹 로직 구현** <br/>
```swift
// APIManager
func fetchURL(page: Int, maxResults: Int, completion: @escaping (Result<[YoutubeModel], NetworkError>) -> Void) {
        let urlString = "\(baseURL)&page=\(page)&maxResults=\(maxResults)"
        fetchData(url: urlString, completion: completion)
    }
    
func fetchData(url: String, completion: @escaping (Result<[YoutubeModel], NetworkError>) -> Void) {
    guard let url = URL(string: url) else {
        completion(.failure(.networkingError))
        return
    }
        
    let session = URLSession(configuration: .default)
        
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
```
   

3. **뷰 반영**  <br/>
dataSource를 전역변수로 생성하고 컬렉션뷰에 연결하고, cellProvider 클로저를 이용해 각 case에 맞는 셀을 반환해 생성합니다.
```swift
// MainViewController
override func viewDidLoad() {
    super.viewDidLoad()
    loadPage()
    setBinding()
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

// MainView
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
```

4. **스크롤 처리**  <br/>
```swift
// MainView
private var currentPage = 0

func loadPage() {
    currentPage += 1
    viewModel.setData(page: currentPage, maxResults: Constants.maxResults)
}

func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let currentRow = indexPath.row

    if currentRow < viewModel.totalDataCount 
        && (currentRow % Constants.maxResults) == Constants.maxResults - 5
        && (currentRow / Constants.maxResults) == (currentPage - 1) {
        loadPage()
    }
}
```


<br/>

## 🤓 Trouble Shooting
- 네트워킹 성공 시 받아오는 데이터를 반환해야 하는 문제
    
    네트워킹은 시간이 오래 걸리는 작업이라 비동기로 처리해야해서 완료된 데이터를 반환할때 @escaping 클로저를 사용해 문제를 해결했습니다. 또한, `Result Type`을 사용해서 네트워킹 성공과 실패를 명확하게 구분할 수 있도록 구현했습니다.
    
- 이미지 데이터를 받아올 때까지 앱이 멈춰있는 문제
    
    @escaping 클로저로 비동기 처리를 해서 이미지가 다운로드 될 때까지 앱이 멈춰있지 않게 처리했습니다. 또한, 앱의 안정성을 위해 UI 관련 작업은 메인 스레드에서 수행해야하기때문에 비동기적으로 이미지 다운로드를 완료하면  `DispatchQueue.main.async` 를 사용하여 메인 스레드에서 이미지를 처리하고 UI 업데이트를 수행했습니다.
