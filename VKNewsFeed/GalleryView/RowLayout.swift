//
//  RowLayout.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 12.01.2022.
//

import Foundation
import UIKit

protocol RowLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, photoAtIndexPath indexPath: IndexPath) -> CGSize
}

class RowLayout: UICollectionViewLayout {
    weak var delegate: RowLayoutDelegate!
    
    static var numbersOfRows = 2
    fileprivate var cellPadding: CGFloat = 8
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentWidth: CGFloat = 0
    // constant
    fileprivate var contentHeight: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.left + insets.right) //why left&right not top&bottom?
        
    }
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        // work around the bug when reusing these properties
        contentWidth = 0
        cache = []
        
        guard cache.isEmpty, let collectionView = collectionView else { return }
        var photoSizes = [CGSize]()
        for i in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: i, section: 0)
            let photoSize = delegate.collectionView(collectionView, photoAtIndexPath: indexPath)
            photoSizes.append(photoSize)
        }
        
        guard let contentHeight = RowLayout.contentHeightCalc(superViewWidth: collectionView.frame.width, photoSizes: photoSizes) else { return }
        let rowHeight = contentHeight / CGFloat(RowLayout.numbersOfRows)
        
        let photosRatio = photoSizes.map { $0.height / $0.width }
        
        var yOffsets = [CGFloat]()
        for row in 0..<RowLayout.numbersOfRows {
            yOffsets.append(CGFloat(row) * rowHeight)
        }
        var xOffsets = [CGFloat](repeating: 0, count: RowLayout.numbersOfRows)
        
        var currentRow = 0
        for i in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: i, section: 0)
            let ratio = photosRatio[indexPath.row]
            let width = rowHeight / ratio
            let frame = CGRect(x: xOffsets[currentRow], y: yOffsets[currentRow], width: width, height: rowHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = insetFrame
            cache.append(attribute)
            
            contentWidth = max(contentWidth, frame.maxX)
            xOffsets[currentRow] += width
            currentRow = currentRow < (RowLayout.numbersOfRows - 1) ? (currentRow + 1) : 0
        }
        
    }
    
    static func contentHeightCalc(superViewWidth: CGFloat, photoSizes: [CGSize]) -> CGFloat? {
        let photoSizeWithMinRatio = photoSizes.min { first, second in
            first.height / first.width < second.height / second.width
        }
        guard let photoSizeWithMinRatio = photoSizeWithMinRatio else { return nil }
        let difference = superViewWidth / photoSizeWithMinRatio.width
        let rowHeight = photoSizeWithMinRatio.height * difference
        return rowHeight * CGFloat(RowLayout.numbersOfRows)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.row]
    }
}
