//
//  ViewController.swift
//  CompositionalLayout
//
//  Created by Ewen on 2021/10/6.
//

import UIKit

class ViewController: UIViewController {
    var photos = [Photo]()

    // 自訂函式 createLayout()，會回傳 compositional layout 物件
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    static func createLayout() -> UICollectionViewLayout {
        let padding: CGFloat = 2
        
        //===
        let singletItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2/3),
                heightDimension: .fractionalHeight(1)
            )
        )
        singletItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding/2, bottom: 0, trailing: padding/2)
        
        let doubletItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1) // 所屬 group 已經有 count: 2 ，故填什麼都沒差
            )
        )
        let doubletVerticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1)
            ),
            subitem: doubletItem, count: 2
        )
        doubletVerticalGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding/2, bottom: 0, trailing: padding/2)
        doubletVerticalGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(padding)
        
        let singletDoubletHorizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(2/3)
            ),
            subitems: [singletItem, doubletVerticalGroup]
        )
        singletDoubletHorizontalGroup.contentInsets = NSDirectionalEdgeInsets(top: padding/2, leading: 0, bottom: padding/2, trailing: 0)
        
        //===
        let tripletItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1), // 所屬 group 已經有 count: 3，故填什麼都沒差
                heightDimension: .fractionalHeight(1)
            )
        )
        tripletItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding/2, bottom: 0, trailing: padding/2)
        
        let tripletHorizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/3)
            ),
            subitem: tripletItem, count: 3
        )
        tripletHorizontalGroup.contentInsets = NSDirectionalEdgeInsets(top: padding/2, leading: 0, bottom: padding/2, trailing: 0)
        
        //===
        let baseVerticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1)
            ),
            subitems: [singletDoubletHorizontalGroup, tripletHorizontalGroup]
        )
        
        let section = NSCollectionLayoutSection(group: baseVerticalGroup)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        //抓一次SearchData
        fetchSearchData()
    }
    
    func fetchSearchData() {
        let privateKey = "YOUR KEY"
        let searchText = "penguins"
        let imageCountPerPage = 96
        let maxUploadDate = "2021-05-05%2023:59:59"
        let minUploadDate = "2021-01-01%2000:00:00"
        
        if let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(privateKey)&text=\(searchText)&per_page=\(imageCountPerPage)&max_upload_date=\(maxUploadDate)&min_upload_date=\(minUploadDate)&format=json&nojsoncallback=1")
        {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
                if let data = data {
                    do {
                        let searchData = try JSONDecoder().decode(SearchData.self, from: data)
                        self.photos = searchData.photos.photo
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    catch {
                        print("Can't parse JSON.")
                    }
                }
            }
            dataTask.resume()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        let photo = photos[indexPath.item]
        cell.imageURL = photo.imageUrl
        cell.imageView.image = nil
        
        NetworkHelper.downloadImage(url: cell.imageURL) { image in
            if let image = image, cell.imageURL == photo.imageUrl {
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
        }
        
        return cell
    }
}

class NetworkHelper {
    static func downloadImage(url: URL, handler: @escaping (UIImage?) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data, let image = UIImage(data: data) {
                handler(image)
            } else {
                handler(nil)
            }
        }
        dataTask.resume()
    }
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController
init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
func makeUIViewController(context: Context) -> some UIViewController {
        viewController
    }
func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<UIViewControllerPreview<ViewController>>) {
        return
    }
}
#endif
#if canImport(SwiftUI) && DEBUG
import SwiftUI
// 可加入多個裝置
let deviceNames: [String] = [
    "iPhone 13 Pro Max"
]
@available(iOS 13.0, *)
struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(deviceNames, id: \.self) { deviceName in
            UIViewControllerPreview {
                ViewController()
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }.previewInterfaceOrientation(.portrait)
    }
}
#endif
