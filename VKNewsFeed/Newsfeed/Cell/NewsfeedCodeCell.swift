//
//  NewsfeedCodeCell.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 26.12.2021.
//

import Foundation
import UIKit

protocol NewsfeedCodeCellDelegate: AnyObject {
    func revealPost(for cell: NewsfeedCodeCell)
    func didSelectPhoto(photo: FeedCellPhotoAttachmentViewModel)
}

class NewsfeedCodeCell: UITableViewCell {
    
    static let reuseId = "NewsfeedCodeCell"
    
    weak var delegate: NewsfeedCodeCellDelegate? {
        didSet {
            galleryCollectionView.galleryDelegate = delegate
        }
    }
    
    var viewModel: FeedCellViewModel?
    
    // root layer
    let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    // layers on cardView
    let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let postLabel: UITextView = {
        let textView = UITextView()
        textView.font = Constants.postLabelFont
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        
        // make padding same as it is on an UILabel
        let padding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        
        return textView
    }()
    let moreTextButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(UIColor(hex: 0x669FD4), for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitle("Show more...", for: .normal)
        return button
    }()
    let galleryCollectionView = GalleryCollectionView()
    let postImageView = WebImageView()
    let bottomView = UIView()
    
    // layers on topView
    let iconImageView: WebImageView = {
        let webImageView = WebImageView()
        webImageView.translatesAutoresizingMaskIntoConstraints = false
        webImageView.layer.cornerRadius = Constants.topViewHeight / 2
        webImageView.clipsToBounds = true
        return webImageView
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(hex: 0x2C2D2E)
        return label
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x818C99)
        return label
    }()
    
    // layers on bottomView
    let likesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let commentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let sharesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let viewsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // layers on bottomView subviews
    let likesImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "like")
        return imageView
    }()
    let commentsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "comment")
        return imageView
    }()
    let sharesImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "share")
        return imageView
    }()
    let viewsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "eye")
        return imageView
    }()
    let likesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "555K"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        label.textColor = UIColor(hex: 0x818C99)
        return label
    }()
    let commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        label.textColor = UIColor(hex: 0x818C99)
        return label
    }()
    let sharesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        label.textColor = UIColor(hex: 0x818C99)
        return label
    }()
    let viewsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        label.textColor = UIColor(hex: 0x818C99)
        return label
    }()
    
    override func prepareForReuse() {
        iconImageView.set(imageURL: nil)
        postImageView.set(imageURL: nil)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        moreTextButton.addTarget(self, action: #selector(moreTextButtonTapped), for: .touchUpInside)
        moreTextButton.isUserInteractionEnabled = true
        moreTextButton.isEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postImageViewTapped))
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(tapGestureRecognizer)
        
        overlayFirstLayer()
        overlaySecondLayer()
        overlayThirdLayerOnTopView()
        overlayThirdLayerOnBottomView()
        overlayFourthLayerOnBottomViewSubviews()
    }

    @objc func postImageViewTapped() {
        if let photo = viewModel?.photoAttachments.first {
            delegate?.didSelectPhoto(photo: photo)
        }
    }
    
    @objc func moreTextButtonTapped() {
        delegate?.revealPost(for: self)
    }
    
    func set(viewModel: FeedCellViewModel) {
        self.viewModel = viewModel
        
        iconImageView.set(imageURL: viewModel.iconUrlString)
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        postLabel.text = viewModel.text
        likesLabel.text = viewModel.likes
        commentsLabel.text = viewModel.comments
        sharesLabel.text = viewModel.shares
        viewsLabel.text = viewModel.views
        
        postLabel.frame = viewModel.sizes.postLabelFrame
        moreTextButton.frame = viewModel.sizes.moreTextButtonFrame
        bottomView.frame = viewModel.sizes.bottomViewFrame
        
        if let photoAttachment = viewModel.photoAttachments.first, viewModel.photoAttachments.count == 1 {
            postImageView.set(imageURL: photoAttachment.photoUrlString)
            postImageView.frame = viewModel.sizes.attachmentFrame
            postImageView.isHidden = false
            galleryCollectionView.isHidden = true
        } else if viewModel.photoAttachments.count > 1 {
            postImageView.isHidden = true
            galleryCollectionView.set(photos: viewModel.photoAttachments)
            galleryCollectionView.frame = viewModel.sizes.attachmentFrame
            galleryCollectionView.isHidden = false
        } else {
            postImageView.isHidden = true
            galleryCollectionView.isHidden = true
        }
    }
    
    private func overlayFourthLayerOnBottomViewSubviews() {
        likesView.addSubview(likesImage)
        likesView.addSubview(likesLabel)
        commentsView.addSubview(commentsImage)
        commentsView.addSubview(commentsLabel)
        sharesView.addSubview(sharesImage)
        sharesView.addSubview(sharesLabel)
        viewsView.addSubview(viewsImage)
        viewsView.addSubview(viewsLabel)
        
        constrainFourthLayerSubviews(view: likesView, imageView: likesImage, label: likesLabel)
        constrainFourthLayerSubviews(view: commentsView, imageView: commentsImage, label: commentsLabel)
        constrainFourthLayerSubviews(view: sharesView, imageView: sharesImage, label: sharesLabel)
        constrainFourthLayerSubviews(view: viewsView, imageView: viewsImage, label: viewsLabel)
    }
    
    private func constrainFourthLayerSubviews(view: UIView, imageView: UIImageView, label: UILabel) {
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -2).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Constants.bottomViewSubviewsIconSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.bottomViewSubviewsIconSize).isActive = true

        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 2).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func overlayThirdLayerOnBottomView() {
        bottomView.addSubview(likesView)
        bottomView.addSubview(commentsView)
        bottomView.addSubview(sharesView)
        bottomView.addSubview(viewsView)
        
        likesView.anchor(top: bottomView.topAnchor,
                         leading: bottomView.leadingAnchor,
                         bottom: nil,
                         trailing: nil,
                         size: CGSize(width: Constants.bottomViewSubviewWidth, height: Constants.bottomViewSubviewHeight))
        commentsView.anchor(top: bottomView.topAnchor,
                            leading: likesView.trailingAnchor,
                            bottom: nil,
                            trailing: nil,
                            size: CGSize(width: Constants.bottomViewSubviewWidth, height: Constants.bottomViewSubviewHeight))
        sharesView.anchor(top: bottomView.topAnchor,
                          leading: commentsView.trailingAnchor,
                          bottom: nil,
                          trailing: nil,
                          size: CGSize(width: Constants.bottomViewSubviewWidth, height: Constants.bottomViewSubviewHeight))
        viewsView.anchor(top: bottomView.topAnchor,
                         leading: nil,
                         bottom: nil,
                         trailing: bottomView.trailingAnchor,
                         size: CGSize(width: Constants.bottomViewSubviewWidth, height: Constants.bottomViewSubviewHeight))
    }
    
    private func overlayThirdLayerOnTopView() {
        topView.addSubview(iconImageView)
        topView.addSubview(nameLabel)
        topView.addSubview(dateLabel)
        
        iconImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 2).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Constants.topViewHeight / 2 - 2).isActive = true
        
        dateLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -8).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -2).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
    private func overlaySecondLayer() {
        cardView.addSubview(topView)
        cardView.addSubview(postLabel)
        cardView.addSubview(moreTextButton)
        cardView.addSubview(galleryCollectionView)
        cardView.addSubview(postImageView)
        cardView.addSubview(bottomView)
        
        topView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8).isActive = true
        topView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8).isActive = true
        topView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8).isActive = true
        topView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        // over constrains are not needed, they are installed automatically
    }
    
    private func overlayFirstLayer() {
        contentView.addSubview(cardView)
        cardView.fillSuperview(padding: Constants.cardInserts)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
