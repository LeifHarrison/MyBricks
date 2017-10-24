//
//  SetDetailViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/19/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SetDetailViewController: UIViewController {

    @IBOutlet weak var setImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var subthemeLabel: UILabel!
    @IBOutlet weak var piecesLabel: UILabel!
    @IBOutlet weak var minifigsLabel: UILabel!

    var currentSet : Set?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let set = currentSet {
            if let urlString = set.imageURL, let url = URL(string: urlString) {
                setImageView.af_setImage(withURL: url)
            }

            nameLabel.text = set.name
            setNumberLabel.text = set.number
            subthemeLabel.text = set.subtheme
            piecesLabel.text = "\(set.pieces ?? 0)"
            minifigsLabel.text = "\(set.minifigs ?? 0)"
        }
        else {
            setImageView.image = nil
            nameLabel.text = ""
            setNumberLabel.text = ""
            subthemeLabel.text = ""
            piecesLabel.text = "0"
            minifigsLabel.text = "0"
        }
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
