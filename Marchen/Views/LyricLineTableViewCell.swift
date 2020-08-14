//
//  LyricLineTableViewCell.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/27.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit

class LyricLineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lyricTextField: MyTextField!
    @IBOutlet weak var underlineView: UIView!
    
    var delegate: AppendNewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lyricTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func onEditChanged(_ sender: UITextField!) {
        
        if let txt = sender.text {
            if txt.count > 20 {
                // 20자를 넘어가는 텍스트 입력시 선택된 line 밑에 새로운 line을 추가하고 그걸 선택, 타이핑까지 옮김.
                let endIndex = txt.index(txt.startIndex, offsetBy: 20)
                sender.text = String(txt[..<endIndex])
                
                let afterText = String(txt[endIndex...])
                delegate?.appendNewCellWithText(text: afterText)
            } else {
                // 20자 이하이면 OK.
            }
        }
        
    }
    
}
