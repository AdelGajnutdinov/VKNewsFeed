//
//  GradientView.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 15.01.2022.
//

import Foundation
import UIKit

class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    @IBInspectable private var startColor: UIColor? {
        didSet {
            setupGradientColors()
        }
    }
    @IBInspectable private var endColor: UIColor? {
        didSet {
            setupGradientColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        self.layer.addSublayer(gradientLayer)
        setupGradientColors()
    }
    
    private func setupGradientColors() {
        guard let startColor = startColor, let endColor = endColor else { return }
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
