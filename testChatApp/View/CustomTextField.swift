//
//  CustomTextField.swift
//  testChatApp
//
//  Created by Julian Silvestri on 2022-02-03.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    override  func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupTextField()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextField()
    }
    
    func setupTextField(){
        layer.cornerRadius = 8
    }
    

}
