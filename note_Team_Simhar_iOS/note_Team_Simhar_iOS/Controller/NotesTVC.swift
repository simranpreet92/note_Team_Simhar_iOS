//
//  NotesTVC.swift
//  note_team_Simhar_iOS
//
//  Created by Simranpreet kaur on 2021-05-28.


import UIKit
import CoreData

class NotesTVC: UITableViewController {

  
    @IBOutlet weak var sortBtn: UIBarButtonItem!
    @IBOutlet weak var trashBtn: UIBarButtonItem!
    @IBOutlet weak var moveBtn: UIBarButtonItem!
    let date = Date()
    let formatter = DateFormatter()
    
    var deletingMovingOption: Bool = false
    
    // create notes
    var notes = [Note]()
    var selectedFolder: NotesFolder? {
        didSet {
            loadSavedNotes()
        }
    }
    
    // create the context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // define a search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = selectedFolder?.name
        showSearchBar()

      
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note_cell", for: indexPath)
        let note = notes[indexPath.row]
      
        formatter.dateFormat = "dd.MM.yyyy"
        
        let result = formatter.string(from: date)
        note.currentDate = result
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = note.title! + "      " + note.currentDate!
        cell.detailTextLabel?.textColor = .white
        let backgroundImage = UIImage(named: "n3")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
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
            deleteSelectedNote(note: notes[indexPath.row])
            saveSelectedNote()
            notes.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
          
        }
    }
    
    //MARK: - Core data interaction functions
    
    /// load notes deom core data
    /// - Parameter predicate: parameter comming from search bar - by default is nil
    func loadSavedNotes(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
      
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
        }
        
        do {
            notes = try context.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    /// delete notes from context
    /// - Parameter note: note defined in Core Data
    func deleteSelectedNote(note: Note) {
        context.delete(note)
    }
    
    /// update note in core data
    /// - Parameter title: note's title
    func updateSelectedNote(with title: String , with image : Data , with text : String , with audio : String , with userLocationL : Double , with userLocationLong : Double)
   // func updateNote(with title: String)
    {   notes = []
        let newNote = Note(context: context)
        newNote.title = title
        newNote.image = image
        print("saved image" , newNote.image)
        newNote.body = text
        newNote.audio = audio
        newNote.lattitude = userLocationL
        newNote.longitude = userLocationLong
        print("userLt" , newNote.lattitude)
        print("userLg" , newNote.longitude)
        newNote.parentFolder = selectedFolder
            saveSelectedNote()
        loadSavedNotes()
    }
    
    /// Save notes into core data
    func saveSelectedNote() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    //MARK: - Action methods
    
    /// trash bar button functionality
    /// - Parameter sender: bar button
    @IBAction func trashBtnPressed(_ sender: UIBarButtonItem) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let rows = (indexPaths.map {$0.row}).sorted(by: >)
            
            let _ = rows.map {deleteSelectedNote(note: notes[$0])}
            let _ = rows.map {notes.remove(at: $0)}
            
            tableView.reloadData()
            saveSelectedNote()
        }
    }
    
    /// editing option functionality - when three dots is pressed this function is executed
    /// - Parameter sender: bar button
    @IBAction func editingBtnPressed(_ sender: UIBarButtonItem) {
        deletingMovingOption = !deletingMovingOption
        
        trashBtn.isEnabled = !trashBtn.isEnabled
        moveBtn.isEnabled = !moveBtn.isEnabled
        
        tableView.setEditing(deletingMovingOption, animated: true)
    }
    
    //MARK: - show search bar func
    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Note"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != "moveNotesSegue" else {
            return true
        }
        return deletingMovingOption ? false : true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? singleNoteVC {
            destination.delegate = self
            
            if let cell = sender as? UITableViewCell {
                if let index = tableView.indexPath(for: cell)?.row {
                    destination.noteChosen = notes[index]
                }
            }
        }
        
        if let destination = segue.destination as? moveNoteVC {
            if let index = tableView.indexPathsForSelectedRows {
                let rows = index.map {$0.row}
                destination.selectedNotes = rows.map {notes[$0]}
            }
        }
    }
    
    @IBAction func unwindToNoteTVC(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        saveSelectedNote()
        loadSavedNotes()
        tableView.setEditing(false, animated: true)
    }
}

//MARK: - search bar delegate methods
extension NotesTVC: UISearchBarDelegate {
    
    
    /// search button on keypad functionality
    /// - Parameter searchBar: search bar is passed to this function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadSavedNotes(predicate: predicate)
    }
    
    
    /// when the text in text bar is changed
    /// - Parameters:
    ///   - searchBar: search bar is passed to this function
    ///   - searchText: the text that is written in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadSavedNotes()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}


