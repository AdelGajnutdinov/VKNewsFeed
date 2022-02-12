//
//  NewsfeedModels.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 18.12.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum Newsfeed {
    enum Model {
        struct Request {
            enum RequestType {
                case getUser
                case getNewsfeed
                case revealPost(postId: Int)
                case getNextBatch
                case searchNewsfeed(query: String)
            }
        }
        struct Response {
            enum ResponseType {
                case presentNewsfeed(feed: FeedResponse, revealedPostIds: [Int])
                case presentUserInfo(userInfo: UserResponse?)
                case presentFooterLoader
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayNewsfeed(feedViewModel: FeedViewModel)
                case displayUser(userViewModel: UserViewModel)
                case displayFooterLoader
            }
        }
    }
}

struct UserViewModel: TitleViewViewModel {
    var photoUrlString: String?
}

struct FeedViewModel {
    struct Cell: FeedCellViewModel {
        var postId: Int
        var iconUrlString: String
        var name: String
        var date: String
        var text: String?
        var likes: String?
        var comments: String?
        var shares: String?
        var views: String?
        var photoAttachments: [FeedCellPhotoAttachmentViewModel]
        var sizes: FeedCellSizes
    }
    
    struct FeedCellPhotoAttachment: FeedCellPhotoAttachmentViewModel {
        var photoUrlString: String?
        var height: Int
        var width: Int
        
        var originalPhotoUrlString: String?
        var originalHeight: Int
        var originalWidth: Int
    }
    
    let cells: [Cell]
    let footerTitle: String?
}
