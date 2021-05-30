//
//  singleNoteVC.swift
//  note_team_Simhar_iOS
//
//  Created by Simranpreet kaur on 2021-05-28.
//

import UIKit

class singleNoteVC: UIViewController , UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    let imagePicker = UIImagePickerController()

    var noteChosen: Note? {
        didSet {
            editNote = true
        }
    }
    
    // edit mode by default is false
    var editNote: Bool = false
    

    weak var delegate: NotesTVC?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextView.text = noteChosen?.title
        noteTextView.text = noteChosen?.body
        imagePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if editNote {
            delegate!.deleteSelectedNote(note: noteChosen!)
           
        }
        guard noteTextView.text != "" || imageView.image != nil else {return}
        delegate!.updateSelectedNote(with: titleTextView.text! , with: (imageView.image?.pngData())! , with : noteTextView.text! )
    }
    @IBAction func pictureBtn(_ sender: UITapGestureRecognizer) {
       
       imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
           imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
      
    }
   func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info:  [UIImagePickerController.InfoKey : Any])

    {
    if  let chosenImage = info[.editedImage] as? UIImage
      {
        imageView.image = chosenImage
         //saving image into binary data
       
        let imageInstance = Note(context: context)
        imageInstance.image = chosenImage.pngData()
        
        print(imageInstance.image)
        print(chosenImage.pngData())
        print(chosenImage)
        do {
        try context.save()
        print("Image is saved")
        } catch {
        print(error.localizedDescription)
              }

      }
      else{
      
      }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true, completion: nil)
      
        }
  
 
   
}
