//
//  ChordTableViewCell.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/29.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit

protocol ChordPlayable {
    func play()
    func stop()
}

class ChordTableViewCell: UITableViewCell {

    @IBOutlet weak var chordTextLabel: PaddedLabel!
    @IBOutlet weak var chordPlayButton: UIButton!
    
    var isPlaying: Bool = false
    var delegate: ChordPlayable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        isPlaying = !isPlaying
        
        DispatchQueue.main.async {
            if (self.isPlaying) {
                // Stop Button Image
                self.chordPlayButton.setImage(UIImage(systemName: "stop.circle"), for: .normal)
                self.delegate?.play()
            } else {
                // Play Button Image
                self.chordPlayButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
                self.delegate?.stop()
            }
        }
        
        
    }
}
