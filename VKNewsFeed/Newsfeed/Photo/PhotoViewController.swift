//
//  PhotoViewController.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 06.02.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: ZoomableImageView!
    
    var photo: FeedCellPhotoAttachmentViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = photo?.originalPhotoUrlString {
            imageView.setImage(by: urlString)
        }
    }
}
