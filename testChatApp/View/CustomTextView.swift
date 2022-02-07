//
//  CustomTextView.swift
//  testChatApp
//
//  Created by Julian Silvestri on 2022-02-04.
//

import UIKit

class CustomTextView: UITextView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        layer.cornerRadius = 8
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
    }

}
