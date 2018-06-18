//
//  ProfileDonateViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/4/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class ProfileDonateViewController: UIViewController {

    @IBOutlet weak var donateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        donateButton.applyDefaultStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
