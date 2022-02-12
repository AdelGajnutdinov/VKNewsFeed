//
//  NewsfeedRouter.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 18.12.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

@objc protocol NewsfeedRoutingLogic {
    func routeToShowPhoto(segue: UIStoryboardSegue)
}

class NewsfeedRouter: NSObject, NewsfeedRoutingLogic {
    
    weak var viewController: NewsfeedViewController?
    
    // MARK: Routing
    func routeToShowPhoto(segue: UIStoryboardSegue) {
        let destinationVC = segue.destination as! PhotoViewController
        destinationVC.photo = viewController?.selectedPhoto
    }
}
