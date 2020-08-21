//
//  SongEditViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/21.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import AudioKit

class SongEditViewController: UIViewController {

    @IBOutlet weak var lyricScrollView: UIScrollView!
    @IBOutlet weak var lyricLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chordProgressionView: UIView!
    @IBOutlet weak var keyboardView: UIStackView!
    
    @IBOutlet weak var containerViewTransitionButton: UIBarButtonItem!
    
    private let myKeyboardView = MyKeyboardView()
    
    private var isKeyboardViewShowing = false
    
    // Internal Variables
    var songTitle: String?
    var songLyric: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        
        // Lyric Scroll View
        lyricScrollView.backgroundColor = .clear
        lyricScrollView.layer.cornerRadius = 5
        lyricScrollView.layer.borderWidth = 1
        lyricScrollView.layer.borderColor = UIColor.label.cgColor
        
        // Lyric Label
        lyricLabel.text = songLyric
        
        // Keyboard View
        myKeyboardView.delegate = self
        myKeyboardView.polyphonicMode = true
        keyboardView.addArrangedSubview(myKeyboardView)
    }
    
    @IBAction func ContainerViewTransition(_ sender: UIBarButtonItem) {
        if isKeyboardViewShowing {
            // Hide KeyboardView
            UIView.transition(from: keyboardView,
            to: chordProgressionView,
            duration: 1.0,
            options: [.transitionFlipFromTop, .showHideTransitionViews],
            completion: nil)
            
            // Change Icon
            containerViewTransitionButton.image = UIImage(systemName: "music.note")
        } else {
            // Show KeyboardView
            UIView.transition(from: chordProgressionView,
            to: keyboardView,
            duration: 1.0,
            options: [.transitionFlipFromTop, .showHideTransitionViews],
            completion: nil)
            
            // Change Icon
            containerViewTransitionButton.image = UIImage(systemName: "music.note.list")
        }
        isKeyboardViewShowing = !isKeyboardViewShowing
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}

extension SongEditViewController: MyKeyboardDelegate {
    
    func noteOn(note: MIDINoteNumber) {
        
    }
    
    func noteOff(note: MIDINoteNumber) {
        
    }
}
