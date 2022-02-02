//
//  NewsfeedWorker.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 18.12.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class NewsfeedService {
    
    var authService: AuthService
    var networking: Networking
    var fetcher: DataFetcher
    
    private var revealedPostIds = [Int]()
    private var feedResponse: FeedResponse?
    private var newFromInProcess: String?
    
    init() {
        self.authService = SceneDelegate.shared().authService
        self.networking = NetworkService(authService: authService)
        self.fetcher = NetworkDataFetcher(networking: networking)
    }
    
    func getUser(completion: @escaping (UserResponse?) -> Void) {
        fetcher.getUser { userResponse in
            completion(userResponse)
        }
    }
    
    func getFeed(completion: @escaping (FeedResponse, [Int]) -> Void) {
        fetcher.getFeed(nextBatchFrom: nil) { [weak self] feedResponse in
            self?.feedResponse = feedResponse
            guard let feedResponse = self?.feedResponse else { return }
            completion(feedResponse, self!.revealedPostIds)
        }
    }
    
    func revealPostIds(forPostId postId: Int, completion: @escaping (FeedResponse, [Int]) -> Void) {
        revealedPostIds.append(postId)
        guard let feedResponse = self.feedResponse else { return }
        completion(feedResponse, revealedPostIds)
    }
    
    func getNextBatch(completion: @escaping (FeedResponse, [Int]) -> Void) {
        newFromInProcess = feedResponse?.nextFrom
        fetcher.getFeed(nextBatchFrom: newFromInProcess) { [weak self] newFeedResponse in
            guard let newFeedResponse = newFeedResponse else { return }
            guard self?.feedResponse?.nextFrom != newFeedResponse.nextFrom else { return }
            
            if self?.feedResponse == nil {
                self?.feedResponse = newFeedResponse
            } else {
                self?.feedResponse?.items.append(contentsOf: newFeedResponse.items)
                self?.feedResponse?.nextFrom = newFeedResponse.nextFrom
                
                var profiles = newFeedResponse.profiles
                if let oldProfiles = self?.feedResponse?.profiles {
                    let oldProfilesFiltered = oldProfiles.filter { oldProfile in
                        !newFeedResponse.profiles.contains { $0.id == oldProfile.id }
                    }
                    profiles.append(contentsOf: oldProfilesFiltered)
                }
                self?.feedResponse?.profiles = profiles
                
                var groups = newFeedResponse.groups
                if let oldGroups = self?.feedResponse?.groups {
                    let oldGroupsFiltered = oldGroups.filter { oldGroup in
                        !newFeedResponse.groups.contains { $0.id == oldGroup.id }
                    }
                    groups.append(contentsOf: oldGroupsFiltered)
                }
                self?.feedResponse?.groups = groups
            }
            
            guard let feedResponse = self?.feedResponse else { return }
            completion(feedResponse, self!.revealedPostIds)
        }
    }
    
    func searchFeed(by query: String, completion: @escaping (FeedResponse, [Int]) -> Void) {
        fetcher.searchFeed(by: query) { [weak self] feedResponse in
            self?.feedResponse = feedResponse
            guard let feedResponse = self?.feedResponse else { return }
            completion(feedResponse, self!.revealedPostIds)
        }
    }
}
