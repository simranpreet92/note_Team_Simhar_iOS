//
//  MoveToVC.swift
//  note_team_Simhar_iOS
//
// Created by Simranpreet kaur on 2021-05-28.
//

import UIKit
import CoreData

class moveNoteVC: UIViewController {

    var folders = [NotesFolder]()
    var selectedNotes: [Note]? {
        didSet {
            loadSavedFolders()
        }
    }
    
    // context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - core data interaction methods
    func loadSavedFolders() {
        let request: NSFetchRequest<NotesFolder> = NotesFolder.fetchRequest()
        
        // predicate
        let folderPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedNotes?[0].parentFolder?.name ?? "")
        request.predicate = folderPredicate
        
        do {
            folders = try context.fetch(request)
        } catch {
            print("Error fetching data \(error.localizedDescription)")
        }
    }
    
    //MARK: - IB Action methods
    
    @IBAction func dismissVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
 
}

extension moveNoteVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = folders[indexPath.row].name
      
        cell.textLabel?.textColor = .lightGray
        cell.textLabel?.tintColor = .lightGray
        let backgroundImage = UIImage(named: "n2")
        let imageView = UIImageView(image: backgroundImage)
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Move to \(folders[indexPath.row].name!)", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Move", style: .default) { (action) in
            for note in self.selectedNotes! {
                note.parentFolder = self.folders[indexPath.row]
            }
            // dismiss the vc
            self.performSegue(withIdentifier: "dismissMoveToVC", sender: self)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        noAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    
}
