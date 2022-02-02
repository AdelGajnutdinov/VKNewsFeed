//
//  UserResponse.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 12.01.2022.
//

import Foundation

struct UserResponseWrapped: Decodable {
    let response: [UserResponse]
}

struct UserResponse: Decodable {
    let photo100: String?
}
