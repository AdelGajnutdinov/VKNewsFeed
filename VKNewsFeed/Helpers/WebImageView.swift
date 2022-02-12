//
//  WebImageView.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 20.12.2021.
//

import UIKit

protocol WebImageViewDelegate {
    func webImageDidLoad()
}

class WebImageView: UIImageView {
    private var currentUrlString: String?
    var delegate: WebImageViewDelegate?
    
    override var image: UIImage? {
        didSet {
            delegate?.webImageDidLoad()
        }
    }
    
    func set(imageURL: String?) {
        self.currentUrlString = imageURL
        
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            self.image = nil
            return
        }
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            self.image = UIImage(data: cachedResponse.data)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, _ in
            if let data = data, let response = response {
                DispatchQueue.main.async {
                    self?.handleLoadedImage(data: data, response: response)
                }
            }
        }.resume()
    }
    
    private func handleLoadedImage(data: Data, response: URLResponse) {
        guard let responseURL = response.url else { return }
        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: responseURL))
        
        // remove "fantom" images when loading current image
        if responseURL.absoluteString == self.currentUrlString {
            self.image = UIImage(data: data)
        }
    }
}
