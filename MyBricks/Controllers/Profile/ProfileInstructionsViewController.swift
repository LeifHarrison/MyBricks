//
//  ProfileInstructionsViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/26/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

import CoreData

class ProfileInstructionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var downloadedInstructions: [DownloadedInstructions] = []
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if downloadedInstructions.count > 0 {
            tableView.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if downloadedInstructions.count == 0 {
            fetchDownloadedInstructions()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func setupTableView() {
        tableView.alwaysBounceVertical = false
        tableView.register(DownloadedInstructionsTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    private func fetchDownloadedInstructions() {
        ActivityOverlayView.show(overView: view)

        let context = DataManager.shared.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedInstructions")
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(DownloadedInstructions.creationDate), ascending: false)]
        do {
            if let fetchedItems = try context.fetch(request) as? [DownloadedInstructions] {
                ActivityOverlayView.hide()
                downloadedInstructions = fetchedItems
                tableView.reloadData()
                updateDisplay(animated: true)
            }
        }
        catch {
            ActivityOverlayView.hide()
            updateDisplay(animated: true)
            fatalError("Failed to fetch search history: \(error)")
        }
    }
    
    private func showPreview(for url: URL) {
        let docInteractionController = UIDocumentInteractionController(url: url)
        docInteractionController.delegate = self
        docInteractionController.presentPreview(animated: true)
    }
    
    private func removeInstructions(_ instructions: DownloadedInstructions, indexPath: IndexPath) {
        //NSLog("Downloaded Instructions count = \(downloadedInstructions.count)")
        // Remove the saved file
        if let url = instructions.fileURL {
            do {
                try FileManager.default.removeItem(at: url)
            }
            catch let error {
                NSLog("Error removing Instructions file: \(error.localizedDescription)")
            }
        }
        
        // Then delete DownloadedInstruction instance
        let context = DataManager.shared.persistentContainer.viewContext
        context.delete(instructions)
        do {
            try context.save()
            downloadedInstructions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        catch let error {
            NSLog("Error saving context: \(error.localizedDescription)")
        }
        //NSLog("Downloaded Instructions count = \(downloadedInstructions.count)")
    }
    
    private func updateDisplay(animated: Bool = false) {
        if downloadedInstructions.count > 0 {
            let item = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEdit(_:)))
            navigationItem.setRightBarButton(item, animated: animated)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: animated)
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func toggleEdit(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        sender.title = tableView.isEditing ? "Done" : "Edit"
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension ProfileInstructionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedInstructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instructions = downloadedInstructions[indexPath.row]
        let cell: DownloadedInstructionsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.populate(with: instructions)
        return cell
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension ProfileInstructionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let instructions = downloadedInstructions[indexPath.row]
        if editingStyle == .delete {
            self.removeInstructions(instructions, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let instructions = downloadedInstructions[indexPath.row]
        var actions: [UIContextualAction] = []
        
        let deleteHandler: UIContextualActionHandler = { (action, view, completionHandler) in
            self.removeInstructions(instructions, indexPath: indexPath)
            completionHandler(true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove", handler: deleteHandler)
        actions.append(deleteAction)
        
        if let url = instructions.fileURL {
            let viewHandler: UIContextualActionHandler  = { (action, view, completionHandler) in
                self.showPreview(for: url)
                completionHandler(true)
            }
            let viewAction = UIContextualAction(style: .normal, title: "View", handler: viewHandler)
            viewAction.image = UIImage(named: "viewDocument")
            actions.append(viewAction)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        return configuration
    }
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension ProfileInstructionsViewController: UIDocumentInteractionControllerDelegate {
    
    // Return the view controller from which the UIDocumentInteractionController will present itself.
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
