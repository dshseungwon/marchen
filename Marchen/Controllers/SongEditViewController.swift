//
//  SongEditViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/21.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import AudioKit

class SongEditViewController: UIViewController, MyKeyboardDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chordProgressionView: UIView!
    @IBOutlet weak var keyboardView: UIStackView!
    
    @IBOutlet weak var containerViewTransitionButton: UIBarButtonItem!
    
    private let myKeyboardView = MyKeyboardView()
    
    var isKeyboardViewShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func noteOn(note: MIDINoteNumber) {
        
    }
    
    func noteOff(note: MIDINoteNumber) {
        
    }
}
