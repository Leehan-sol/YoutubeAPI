//
//  YoutubeData.swift
//  YoutubeAPI
//
//  Created by hansol on 2024/07/11.
//

import Foundation

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


