//
//  MyTextField.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/14.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit

protocol MyTextFieldDelegate {
    func deleteLine()
}

class MyTextField: UITextField {
    
    var myDelegate: MyTextFieldDelegate?
    
    override public func deleteBackward() {
        if text == "" {
             // do something when backspace is tapped/entered in an empty text field
            myDelegate?.deleteLine()
        }
        // do something for every backspace
        super.deleteBackward()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
