//
//  API.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 12.12.2021.
//

import Foundation

struct API {
    static let scheme = "https"
    static let host = "api.vk.com"
    static let version = "5.131"
    
    static let newsFeed = "/method/newsfeed.get"
    static let newsFeedSearch = "/method/newsfeed.search"
    static let userInfo = "/method/users.get"
}
