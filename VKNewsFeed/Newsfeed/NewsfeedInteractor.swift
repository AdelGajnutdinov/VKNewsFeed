//
//  NewsfeedInteractor.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 18.12.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol NewsfeedBusinessLogic {
    func makeRequest(request: Newsfeed.Model.Request.RequestType)
}

class NewsfeedInteractor: NewsfeedBusinessLogic {
    
    var presenter: NewsfeedPresentationLogic?
    var service: NewsfeedService?
    
    func makeRequest(request: Newsfeed.Model.Request.RequestType) {
        if service == nil {
            service = NewsfeedService()
        }
        
        switch request {
        case .getNewsfeed:
            service?.getFeed { [weak self] feedResponse, revealedPostIds in
                self?.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealedPostIds: revealedPostIds))
            }
        case .getUser:
            service?.getUser { [weak self] userResponse in
                self?.presenter?.presentData(response: .presentUserInfo(userInfo: userResponse))
            }
        case .revealPost(let postId):
            service?.revealPostIds(forPostId: postId, completion: { [weak self] feedResponse, revealedPostIds in
                self?.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealedPostIds: revealedPostIds))
            })
        case .getNextBatch:
            self.presenter?.presentData(response: .presentFooterLoader)
            service?.getNextBatch { [weak self] feedResponse, revealedPostIds in
                self?.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealedPostIds: revealedPostIds))
            }
        case .searchNewsfeed(query: let query):
            service?.searchFeed(by: query, completion: { [weak self] feedResponse, revealedPostIds in
                self?.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealedPostIds: revealedPostIds))
            })
        }
    }
}
