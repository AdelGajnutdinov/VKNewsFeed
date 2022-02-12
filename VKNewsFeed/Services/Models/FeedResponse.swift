//
//  FeedResponse.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 18.12.2021.
//

import Foundation

struct FeedResponseWrapped: Decodable {
    let response: FeedResponse
}

struct FeedResponse: Decodable {
    var items: [FeedItem]
    var profiles: [Profile]
    var groups: [Group]
    var nextFrom: String?
}

struct FeedItem: Decodable {
    // only feed
    var postId: Int?
    let sourceId: Int?
    
    // only search
    let id: Int?
    let ownerId: Int?
    
    // all
    var postUid: Int { return postId ?? id! }
    var sourceUid: Int { return sourceId ?? ownerId! }
    let text: String?
    let date: Double
    let comments: CountableItem?
    let likes: CountableItem?
    let reposts: CountableItem?
    let views: CountableItem?
    let attachments: [Attachment]?
}

struct Attachment: Decodable {
    let photo: Photo?
}

struct Photo: Decodable {
    let sizes: [PhotoSize]
    
    var photoPreview: PhotoSize {
        return getPhotoSize(inHD: false)
    }
    var originalPhoto: PhotoSize {
        return getPhotoSize(inHD: true)
    }
    
    private func getPhotoSize(inHD: Bool) -> PhotoSize {
        if !inHD, let sizeX = sizes.first(where: { $0.type == "x" }) {
            return sizeX
        } else if inHD, let sizeW = sizes.first(where: { $0.type == "w" }) {
            return sizeW
        } else if let fallBackSize = sizes.last {
            return fallBackSize
        } else {
            return PhotoSize(type: "Wrong photo", url: "Wrong photo", height: 0, width: 0)
        }
    }
}

struct PhotoSize: Decodable {
    let type: String
    let url: String
    let height: Int
    let width: Int
}

struct CountableItem: Decodable {
    let count: Int
}

protocol ProfileRepresentable: Decodable {
    var id: Int { get }
    var name: String { get }
    var photo: String { get }
}

struct Profile: ProfileRepresentable {
    let id: Int
    let firstName: String
    let lastName: String
    let photo100: String
    
    var name: String { return firstName + " " + lastName }
    var photo: String { return photo100 }
}

struct Group: ProfileRepresentable {
    let id: Int
    let name: String
    let photo100: String
    
    var photo: String { return photo100 }
}
