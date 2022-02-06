//
//  InsertableTextField.swift
//  VKNewsFeed
//
//  Created by Adel Gainutdinov on 12.01.2022.
//

import Foundation
import UIKit

protocol DelayableTextField {
    var actionDelay: Double { get set }
    var actionClosure: ((_ text: String?) -> Void)? { get set }
}

class InsertableTextField: UITextField, DelayableTextField {
    
    var actionDelay: Double = 1.0
    var actionClosure: ((_ text: String?) -> Void)?
    
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(hex: 0xEEEEEE)
        placeholder = "Search"
        font = UIFont.systemFont(ofSize: 14)
        clearButtonMode = .whileEditing
        borderStyle = .none
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let image = UIImage(named: "search")
        leftView = UIImageView(image: image)
        leftView?.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
        leftViewMode = .always
        
        self.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        self.returnKeyType = .search
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    @objc func textFieldEditingChanged() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: actionDelay, target: self, selector: #selector(executeAction), userInfo: nil, repeats: false)
    }

    @objc private func executeAction() {
        actionClosure?(self.text)
    }
}

extension InsertableTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.timer?.invalidate()
        self.executeAction()
        return true
    }
}
