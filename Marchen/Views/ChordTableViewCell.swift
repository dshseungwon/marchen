//
//  ChordTableViewCell.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/29.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit

protocol ChordPlayable {
    func play(diatonicProgression: [Diatonic])
    func stop()
}

class ChordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chordTextLabel: PaddedLabel!
    @IBOutlet weak var chordPlayButton: UIButton!
    
    var cellDiatonicProgression: [Diatonic]?   // e.g. [I, V, VI, IV]
    
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
                guard let diatonicProgression = self.cellDiatonicProgression else {
                    fatalError("Cell does not have diatonicProgression")
                }
                self.delegate?.play(diatonicProgression: diatonicProgression)
            } else {
                // Play Button Image
                self.chordPlayButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
                self.delegate?.stop()
            }
        }
    }
}
