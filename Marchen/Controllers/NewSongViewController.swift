//
//  NewSongViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/29.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit

class NewSongViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedLyric : LyricModel?
     {
         didSet {
             loadLyric()
         }
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.ChordCellNibName, bundle: nil), forCellReuseIdentifier: K.ChordCellIdentifier)
        
        tableView.dataSource = self
        
    }
    
    //MARK: - Load Lyric Function
    func loadLyric() {
        title = selectedLyric?.title
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ChordCellIdentifier, for: indexPath) as! ChordTableViewCell
        
        
        return cell
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
