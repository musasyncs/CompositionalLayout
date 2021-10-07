//
//  FeedData.swift
//  CompositionalLayout
//
//  Created by Ewen on 2021/10/7.
//

import Foundation

struct SearchData: Decodable {
    let photos: PhotoData
}
struct PhotoData: Decodable {
    let photo: [Photo]
}
struct Photo: Decodable {
    let farm: Int
    let secret: String
    let id: String
    let server: String
    let title: String
    var imageUrl: URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
    }
}

