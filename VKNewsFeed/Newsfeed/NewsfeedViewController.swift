//
//  NewsfeedViewController.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 18.12.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol NewsfeedDisplayLogic: AnyObject {
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData)
}

class NewsfeedViewController: UIViewController, NewsfeedDisplayLogic, NewsfeedCodeCellDelegate {
    
    var interactor: NewsfeedBusinessLogic?
    var router: (NSObjectProtocol & NewsfeedRoutingLogic)?
    
    @IBOutlet weak var tableView: UITableView!
    private var titleView = TitleView()
    private lazy var footerView = FooterView()
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private var feedViewModel = FeedViewModel.init(cells: [], footerTitle: nil)
    private var searchText: String?
    private(set) var selectedPhoto: FeedCellPhotoAttachmentViewModel?
    
    // MARK: Setup
    private func setup() {
        let viewController        = self
        let interactor            = NewsfeedInteractor()
        let presenter             = NewsfeedPresenter()
        let router                = NewsfeedRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTopBars()
        setupTableView()
        interactor?.makeRequest(request: .getNewsfeed)
        interactor?.makeRequest(request: .getUser)
    }
    
    private func setupTableView() {
//        tableView.register(UINib(nibName: "NewsfeedCell", bundle: nil), forCellReuseIdentifier: NewsfeedCell.reuseId)
        tableView.register(NewsfeedCodeCell.self, forCellReuseIdentifier: NewsfeedCodeCell.reuseId)
        
        tableView.contentInset.top = 8
        tableView.separatorStyle = .none
        tableView.backgroundColor = .none
        
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = footerView
    }
    
    private func setupTopBars() {
        // blank white view under status bar
        if let statusBarFrame = SceneDelegate.shared().window?.windowScene?.statusBarManager?.statusBarFrame {
            let topBar = UIView(frame: statusBarFrame)
            topBar.backgroundColor = .white
            topBar.layer.shadowColor = UIColor.black.cgColor
            topBar.layer.shadowOpacity = 0.3
            topBar.layer.shadowOffset = .zero
            topBar.layer.shadowRadius = 8
            self.view.addSubview(topBar)
        }
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.titleView = titleView
        
        titleView.delegate = self
        titleView.setInsertableTextFieldTextEditedActionDelay(delayInSeconds: 0.7)
    }
    
    @objc private func refreshData() {
        if let searchText = searchText, !searchText.isEmpty {
            interactor?.makeRequest(request: .searchNewsfeed(query: searchText))
        } else {
            interactor?.makeRequest(request: .getNewsfeed)
        }
    }
    
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayNewsfeed(let feedViewModel):
            self.feedViewModel = feedViewModel
            footerView.setTitle(feedViewModel.footerTitle)
            tableView.reloadData()
            refreshControl.endRefreshing()
        case .displayUser(let userViewModel):
            self.titleView.set(userViewModel: userViewModel)
        case .displayFooterLoader:
            footerView.showLoader()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 1.1 {
            interactor?.makeRequest(request: .getNextBatch)
        }
    }
    
    // MARK: NewsfeedCodeCellDelegate
    func revealPost(for cell: NewsfeedCodeCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let cellViewModel = feedViewModel.cells[indexPath.row]
        
        interactor?.makeRequest(request: .revealPost(postId: cellViewModel.postId))
    }
    
    func didSelectPhoto(photo: FeedCellPhotoAttachmentViewModel) {
        selectedPhoto = photo
        performSegue(withIdentifier: "ShowPhoto", sender: nil)
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
}

extension NewsfeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: NewsfeedCell.reuseId, for: indexPath) as! NewsfeedCell
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsfeedCodeCell.reuseId, for: indexPath) as! NewsfeedCodeCell
        cell.set(viewModel: feedViewModel.cells[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return feedViewModel.cells[indexPath.row].sizes.totalHeight
//        return 212
    }
    
    // helps when "Show more..." button pressed
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return feedViewModel.cells[indexPath.row].sizes.totalHeight
    }
}

extension NewsfeedViewController: TitleViewDelegate {
    func searchFieldTextChanged(with text: String?) {
        self.searchText = text
        if let searchText = searchText, !searchText.isEmpty {
            self.interactor?.makeRequest(request: .searchNewsfeed(query: searchText))
        } else {
            self.interactor?.makeRequest(request: .getNewsfeed)
        }
    }
}
