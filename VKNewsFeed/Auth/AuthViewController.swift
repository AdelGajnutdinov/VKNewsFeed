//
//  AuthViewController.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 12.12.2021.
//

import UIKit

class AuthViewController: UIViewController {
    
    private var authService: AuthService!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authService = SceneDelegate.shared().authService
        view.backgroundColor = .gray
    }

    @IBAction func signInTapped(_ sender: Any) {
        authService.wakeUpSession()
    }
    
}

