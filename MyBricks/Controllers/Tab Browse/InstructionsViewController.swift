//
//  InstructionsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import Alamofire

class InstructionsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var currentSet : Set?
    var instructions : [SetInstructions] = []


    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let set = currentSet, let setID = set.setID {
            self.activityIndicator?.startAnimating()
            BricksetServices.shared.getInstructions(setID: setID, completion: { result in
                self.activityIndicator?.stopAnimating()
                self.instructions = result.value ?? []
                self.tableView.reloadData()
            })
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func showProgressView(forCell cell: InstructionsTableViewCell) {
        cell.progressView.alpha = 0.0
        cell.progressView.isHidden = false
        let animations: (() -> Void) = {
            cell.progressView.alpha = 1.0
        }
        UIView.animate(withDuration: 0.2, animations: animations)
    }

    private func flashProgressView(forCell cell: InstructionsTableViewCell) {
        let animations: (() -> Void) = {
            cell.progressView.alpha = 0.5
        }
        UIView.animate(withDuration: 0.2, animations: animations)
    }

    private func previewInstructions(_ instructions: SetInstructions, fromCell cell: InstructionsTableViewCell) -> Void {
        let destination = DownloadRequest.suggestedDownloadDestination()
        
        if let urlString = instructions.url {
            showProgressView(forCell: cell)
            Alamofire.download(urlString, to: destination)
                .downloadProgress { (progress) in
                    cell.progressView.progress = Float(progress.fractionCompleted)
                }
                .validate()
                .responseData { ( response ) in
                    print(response.destinationURL!)
                    let docInteractionController = UIDocumentInteractionController(url: response.destinationURL!)
                    docInteractionController.delegate = self
                    docInteractionController.presentPreview(animated: true)
            }
        }
        
    }

    private func shareInstructions(_ instructions: SetInstructions) -> Void {
        
    }

}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension InstructionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instruction = instructions[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionsTableViewCell", for: indexPath) as? InstructionsTableViewCell {
            if let urlString = instruction.url, let url = URL(string: urlString) {
                cell.filenameLabel.text = url.lastPathComponent
            }
            cell.titleLabel.text = instruction.description
            cell.previewButtonTapped = {
                self.previewInstructions(instruction, fromCell: cell)
            }
            return cell
        }
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension InstructionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instruction = instructions[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? InstructionsTableViewCell {
            self.previewInstructions(instruction, fromCell: cell)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension InstructionsViewController: UIDocumentInteractionControllerDelegate {
    
    // Return the view controller from which the UIDocumentInteractionController will present itself.
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
