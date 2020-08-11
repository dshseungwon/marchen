//
//  NewChordAlertViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/09.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import RealmSwift

protocol UpdateDiatonicProgression {
    func update(diatonicProgression: [Diatonic])
}

class NewChordAlertViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var diatonicProgression: [Diatonic] = []
    
    @IBOutlet weak var label: UILabel!
    
    var delegate: UpdateDiatonicProgression?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.backgroundColor = .clear
        scrollView.layer.cornerRadius = 5
        scrollView.layer.borderWidth = 1
        scrollView.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        backgroundView.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(CGFloat(0.6))
        })
    }
    
    @IBAction func diatonicButtonClicked(_ sender: UIButton) {
        let tag = sender.tag
        let diatonic = Diatonic(rawValue: tag)!
        diatonicProgression.append(diatonic)
        
        var strArray: [String] = []
        for diatonic in diatonicProgression {
            strArray.append(Utils.diatonicToStr(diatonic: diatonic))
        }
        
        var format = "%@"
        for _ in 1 ..< diatonicProgression.count {
            format += " - %@"
        }
        
        let formattedString = String(format: format, arguments: strArray)
        
        label.text = formattedString
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        if diatonicProgression.count != 0 {
            delegate?.update(diatonicProgression: diatonicProgression)
        }
        dismiss(animated: false, completion: nil)
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
