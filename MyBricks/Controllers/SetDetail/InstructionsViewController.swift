//
//  InstructionsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import Alamofire
import CoreData

class InstructionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var currentSet: SetDetail?
    var instructions: [SetInstructions] = []

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if instructions.count > 0 {
            tableView.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if instructions.count == 0 {
            fetchInstructions()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func setupTableView() {
        tableView.register(InstructionsTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    private func fetchInstructions() {
        if let set = currentSet, let setID = set.setID {
            ActivityOverlayView.show(overView: view)
            BricksetServices.shared.getInstructions(setID: setID, completion: { result in
                ActivityOverlayView.hide()
                switch result {
                    case .success(let instructions):
                        self.instructions = instructions
                        self.tableView.reloadData()
                    case .failure(let error):
                        NSLog("Error fetching instructions: \(error.localizedDescription)")
                }
            })
        }
    }
    
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

    private func downloadInstructions(_ instructions: SetInstructions, fromCell cell: InstructionsTableViewCell) {
        guard let urlString = instructions.fileURL, let url = URL(string: urlString) else {
            return
        }
        
        if let destination = destinationURL(for: url), FileManager.default.fileExists(atPath: destination.path) {
            showPreview(for: destination)
            return
        }
        
        let destination = DownloadRequest.suggestedDownloadDestination()
        if let urlString = instructions.fileURL {
            showProgressView(forCell: cell)
            AF.download(urlString, to: destination)
                .downloadProgress { (progress) in
                    cell.progressView.progress = Float(progress.fractionCompleted)
                }
                .validate()
                .responseData { ( response ) in
                    if let destinationURL = response.fileURL {
                        NSLog("destinationURL: \(destinationURL)")
                        self.saveDownloadedInstructions(instructions, destinationURL: destinationURL)
                        NSLog("presentedViewController: \(String(describing: self.presentedViewController))")
                        if self.presentedViewController == nil {
                            self.showPreview(for: destinationURL)
                        }
                    }
            }
        }
        
    }

    private func showPreview(for url: URL) {
        let docInteractionController = UIDocumentInteractionController(url: url)
        docInteractionController.delegate = self
        docInteractionController.presentPreview(animated: true)
    }
    
    fileprivate func saveDownloadedInstructions(_ instructions: SetInstructions, destinationURL: URL) {
        //NSLog("destinationURL: \(destinationURL)")
        var creationDate = Date()
        var fileSize = 0
        do {
            let resourceValues = try destinationURL.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
            if let date = resourceValues.creationDate {
                creationDate = date
            }
            if let size = resourceValues.fileSize {
                fileSize = size
            }
        }
        catch let error {
            NSLog("Error getting resource values: \(error)")
        }
        //NSLog("creationDate: \(creationDate)")
        //NSLog("fileSize: \(fileSize)")

        let container = DataManager.shared.persistentContainer
        let saveBlock = { (context: NSManagedObjectContext) in
            do {
                let downloadedInstructions = DownloadedInstructions(context: context)
                downloadedInstructions.creationDate = creationDate
                downloadedInstructions.fileDescription = instructions.fileDescription
                downloadedInstructions.fileName = destinationURL.lastPathComponent
                downloadedInstructions.fileSize = Int64(fileSize)
                downloadedInstructions.setName = self.currentSet?.name
                downloadedInstructions.setNumber = self.currentSet?.fullSetNumber
                //NSLog("downloadedInstructions: \(downloadedInstructions)")
                try context.save()
            }
            catch {
                NSLog("Failed to save downloaded instructions: \(error)")
            }
        }
        container.performBackgroundTask(saveBlock)
    }
    
    private func shareInstructions(_ instructions: SetInstructions) {
        
    }

    private func destinationURL(for url: URL) -> URL? {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if !directoryURLs.isEmpty {
            return directoryURLs[0].appendingPathComponent(url.lastPathComponent)
        }
        return nil
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
            cell.populate(with: instruction)
            cell.previewButtonTapped = {
                self.downloadInstructions(instruction, fromCell: cell)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let instructionsCell = cell as? InstructionsTableViewCell {
            let instruction = instructions[indexPath.row]
            if let destination = instruction.destinationURL, FileManager.default.fileExists(atPath: destination.path) {
                instructionsCell.previewButton.imageView?.image = #imageLiteral(resourceName: "documentView")
            }
            else {
                instructionsCell.previewButton.imageView?.image = #imageLiteral(resourceName: "documentDownload")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instruction = instructions[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? InstructionsTableViewCell {
            downloadInstructions(instruction, fromCell: cell)
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
