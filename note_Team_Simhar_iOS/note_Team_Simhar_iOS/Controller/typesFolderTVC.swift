//
//  FolderTVC.swift
//  Note Demo Template
//
//  Created by Mohammad Kiani on 2021-01-27.
//  Copyright © 2021 mohammadkiani. All rights reserved.
//

import UIKit
import CoreData

class typesFolderTVC: UITableViewController {
    
    // create a folder array to populate the table
    var folders = [Folder]()
    
    // create a context to work with core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFolders()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return folders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folder_cell", for: indexPath)
        
        cell.textLabel?.text = folders[indexPath.row].name
        cell.textLabel?.textColor = .lightGray
        cell.detailTextLabel?.textColor = .lightGray
        cell.detailTextLabel?.text = "\(folders[indexPath.row].notes?.count ?? 0)"
        cell.imageView?.image = UIImage(systemName: "folder")
        cell.selectionStyle = .none
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteFolder(folder: folders[indexPath.row])
            saveFolders()
            folders.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    //MARK: - IB Action methods
    
    /// add folder button pressed
    /// - Parameter sender: bar button
    @IBAction func addFolderBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Folder", message: "please give a name", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let folderNames = self.folders.map {$0.name?.lowercased()}
            guard !folderNames.contains(textField.text?.lowercased()) else {self.showAlert(); return}
            let newFolder = Folder(context: self.context)
            newFolder.name = textField.text!
            self.folders.append(newFolder)
            self.saveFolders()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // change the color of the cancel button action
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "folder name"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    /// show alert when the name of the folder is taken
    func showAlert() {
        let alert = UIAlertController(title: "Name Taken", message: "Please choose another name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - core data interaction methods
    
    /// load folder from core data
    func loadFolders() {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        do {
            folders = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    /// save folders into core data
    func saveFolders() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the folder \(error.localizedDescription)")
        }
    }
    
    func deleteFolder(folder: Folder) {
        context.delete(folder)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! NotesTVC
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedFolder = folders[indexPath.row]
        }
    }
    

}
