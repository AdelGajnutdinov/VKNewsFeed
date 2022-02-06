//
//  NetworkDataFetcher.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 18.12.2021.
//

import Foundation

protocol DataFetcher {
    func getFeed(nextBatchFrom: String?, response: @escaping (FeedResponse?) -> Void)
    func getUser(response: @escaping (UserResponse?) -> Void)
    func searchFeed(by query: String, nextBatchFrom: String?, response: @escaping (FeedResponse?) -> Void)
}

struct NetworkDataFetcher: DataFetcher {
    
    private let authService: AuthService
    private let networking: Networking
    
    init(authService: AuthService = SceneDelegate.shared().authService, networking: Networking) {
        self.authService = authService
        self.networking = networking
    }
    
    func getFeed(nextBatchFrom: String?, response: @escaping (FeedResponse?) -> Void) {
        var params = ["filters" : "post,photo"]
        params["start_from"] = nextBatchFrom
        networking.request(path: API.newsFeed, with: params) { data, error in
            if let error = error {
                print("Error received requesting data:", error.localizedDescription)
                response(nil)
            }
            let decoded = decodeJSON(type: FeedResponseWrapped.self, from: data)
            response(decoded?.response)
        }
    }
    
    func getUser(response: @escaping (UserResponse?) -> Void) {
        guard let userId = authService.userId else { return }
        let params = ["user_ids" : userId, "fields" : "photo_100"]
        networking.request(path: API.userInfo, with: params) { data, error in
            if let error = error {
                print("Error received requesting data:", error.localizedDescription)
                response(nil)
            }
            let decoded = decodeJSON(type: UserResponseWrapped.self, from: data)
            response(decoded?.response.first)
        }
    }
    
    func searchFeed(by query: String, nextBatchFrom: String?, response: @escaping (FeedResponse?) -> Void) {
        var params = ["q" : query]
        params["count"] = "50"
        params["extended"] = "1"
        params["start_from"] = nextBatchFrom
        networking.request(path: API.newsFeedSearch, with: params) { data, error in
            if let error = error {
                print("Error received requesting data:", error.localizedDescription)
                response(nil)
            }
            let decoded = decodeJSON(type: FeedResponseWrapped.self, from: data)
            response(decoded?.response)
        }
    }
    
    private func decodeJSON<T: Decodable> (type: T.Type, from data: Data?) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = data else { return nil }
        
        do {
            let response = try decoder.decode(type.self, from: data)
            return response
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }
}
