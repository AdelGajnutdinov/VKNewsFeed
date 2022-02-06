//
//  TitleView.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 12.01.2022.
//

import Foundation
import UIKit

protocol TitleViewViewModel {
    var photoUrlString: String? { get }
}

protocol TitleViewDelegate: AnyObject {
    func searchFieldTextChanged(with text: String?)
}

class TitleView: UIView {
    
    weak var delegate: TitleViewDelegate?
    
    private var searchField: (UITextField & DelayableTextField)!
    
    private var avatar: WebImageView = {
        let imageView = WebImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .orange
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        searchField = InsertableTextField()
        searchField.actionClosure = { [unowned self] text in
            self.delegate?.searchFieldTextChanged(with: text)
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchField)
        addSubview(avatar)
        
        constrainViews()
    }
    
    func set(userViewModel: TitleViewViewModel) {
        avatar.set(imageURL: userViewModel.photoUrlString)
    }
    
    private func constrainViews() {
        avatar.anchor(top: topAnchor,
                      leading: nil,
                      bottom: nil,
                      trailing: trailingAnchor,
                      padding: UIEdgeInsets(top: 4, left: 777, bottom: 777, right: 4))
        avatar.heightAnchor.constraint(equalTo: searchField.heightAnchor, multiplier: 1).isActive = true
        avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1).isActive = true
        
        searchField.anchor(top: topAnchor,
                           leading: leadingAnchor,
                           bottom: bottomAnchor,
                           trailing: avatar.leadingAnchor,
                           padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 12))
    }
    
    // navigation bar ad hoc
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = avatar.frame.width / 2
    }
    
    func setInsertableTextFieldTextEditedActionDelay(delayInSeconds: Double) {
        searchField.actionDelay = delayInSeconds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
