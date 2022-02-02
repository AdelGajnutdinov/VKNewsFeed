//
//  NewsfeedCellLayoutCalculator.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 25.12.2021.
//

import Foundation
import UIKit

struct Sizes: FeedCellSizes {
    var postLabelFrame: CGRect
    var moreTextButtonFrame: CGRect
    var attachmentFrame: CGRect
    var bottomViewFrame: CGRect
    var totalHeight: CGFloat
}

protocol FeedCellLayoutCalculatorProtocol {
    func sizes(postText: String?, photoAttachments: [FeedCellPhotoAttachmentViewModel], isFullSizedPost: Bool) -> FeedCellSizes
}

final class NewsfeedCellLayoutCalculator: FeedCellLayoutCalculatorProtocol {
    
    private let screenWidth: CGFloat
    
    init(screenWidth: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)) {
        self.screenWidth = screenWidth
    }
    
    func sizes(postText: String?, photoAttachments: [FeedCellPhotoAttachmentViewModel], isFullSizedPost: Bool) -> FeedCellSizes {
        var showMoreTextButton = false
        let cardViewWidth = screenWidth - Constants.cardInserts.left - Constants.cardInserts.right
        
        // MARK: PostLabelFrame calculation
        var postLabelFrame = CGRect(origin: CGPoint(x: Constants.postLabelInserts.left, y: Constants.postLabelInserts.top),
                                    size: CGSize.zero)
        if let postText = postText, !postText.isEmpty {
            let width = cardViewWidth - Constants.postLabelInserts.left - Constants.postLabelInserts.right
            var height = postText.height(width: width, font: Constants.postLabelFont)
            let limitHeight = Constants.postLabelFont.lineHeight * Constants.minifiedPostLimitLines
            
            if !isFullSizedPost && height > limitHeight {
                height = Constants.postLabelFont.lineHeight * Constants.minifiedPostLines
                showMoreTextButton = true
            }
            
            postLabelFrame.size = CGSize(width: width, height: height)
        }
        
        // MARK: MoreTextButtonFrame calculation
        let moreTextButtonSize = showMoreTextButton ? Constants.moreTextButtonSize : CGSize.zero
        let moreTextButtonOrigin = CGPoint(x: Constants.moreTextButtonInserts.left, y: postLabelFrame.maxY + Constants.postLabelInserts.bottom)
        let moreTextButtonFrame = CGRect(origin: moreTextButtonOrigin, size: moreTextButtonSize)
        
        // MARK: AttachmentFrame calculation
        let attachmentTop = postLabelFrame.size == CGSize.zero ? Constants.postLabelInserts.top : moreTextButtonFrame.maxY + Constants.postLabelInserts.bottom
        var attachmentFrame = CGRect(origin: CGPoint(x: 0, y: attachmentTop),
                                     size: CGSize.zero)
//        if let photoAttachment = photoAttachment {
//            let ratio = CGFloat(photoAttachment.height) / CGFloat(photoAttachment.width)
//            attachmentFrame.size = CGSize(width: cardViewWidth,
//                                          height: cardViewWidth * ratio)
//        }
        if let photoAttachment = photoAttachments.first {
            let ratio = CGFloat(photoAttachment.height) / CGFloat(photoAttachment.width)
            if photoAttachments.count == 1 {
                attachmentFrame.size = CGSize(width: cardViewWidth, height: cardViewWidth * ratio)
            } else if photoAttachments.count > 1 {
                var photoSizes = [CGSize]()
                for photo in photoAttachments {
                    let photoSize = CGSize(width: photo.width, height: photo.height)
                    photoSizes.append(photoSize)
                }
                let rowHeight = RowLayout.contentHeightCalc(superViewWidth: cardViewWidth, photoSizes: photoSizes)
                attachmentFrame.size = CGSize(width: cardViewWidth, height: rowHeight!)
            }
        }
        
        // MARK: BottomViewFrame calculation
        let bottomViewTop = max(postLabelFrame.maxY, attachmentFrame.maxY)
        let bottomViewFrame = CGRect(origin: CGPoint(x: 0, y: bottomViewTop),
                                     size: CGSize(width: cardViewWidth, height: Constants.bottomViewHeight))
        
        // MARK: TotalHeight calculation
        let totalHeight = bottomViewFrame.maxY + Constants.cardInserts.bottom
//        print(Sizes(postLabelFrame: postLabelFrame,
//                    moreTextButtonFrame: moreTextButtonFrame,
//                    attachmentFrame: attachmentFrame,
//                    bottomViewFrame: bottomViewFrame,
//                    totalHeight: totalHeight))
        return Sizes(postLabelFrame: postLabelFrame,
                     moreTextButtonFrame: moreTextButtonFrame,
                     attachmentFrame: attachmentFrame,
                     bottomViewFrame: bottomViewFrame,
                     totalHeight: totalHeight)
    }
}
