//
//  NoteVC.swift
//  Note Demo Template
//
//  Created by Mohammad Kiani on 2021-01-28.
//  Copyright © 2021 mohammadkiani. All rights reserved.
//

import UIKit

class singleNoteVC: UIViewController , UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    let imagePicker = UIImagePickerController()
    
    var selectedNote: Note? {
        didSet {
            editMode = true
        }
    }
    
    // edit mode by default is false
    var editMode: Bool = false
    
    // an in instance of the noteTVC in noteVC - delegate
    weak var delegate: NotesTVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noteTextView.text = selectedNote?.title
        imagePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if editMode {
            delegate!.deleteNote(note: selectedNote!)
        }
        guard noteTextView.text != "" else {return}
        delegate!.updateNote(with: noteTextView.text )
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
    
      }
      else{
      
      }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true, completion: nil)
      
        }
  
 
   
}
