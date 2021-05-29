//
//  NoteVC.swift
//  Note Demo Template
//
//  Created by Mohammad Kiani on 2021-01-28.
//  Copyright © 2021 mohammadkiani. All rights reserved.
//

import UIKit

class singleNoteVC: UIViewController , UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    let imagePicker = UIImagePickerController()
//    static let shareInstance = DataBaseHelper()

    var selectedNote: Note? {
        didSet {
            editMode = true
        }
    }
    
    // edit mode by default is false
    var editMode: Bool = false
    
    // an in instance of the noteTVC in noteVC - delegate
    weak var delegate: NotesTVC?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextView.text = selectedNote?.title
        noteTextView.text = selectedNote?.body
        //imageView.image = UIImage(named: "66")
      /*  let image : UIImage = UIImage(data: (selectedNote?.image)!)!
        imageView.image = image
        print(image)
        print(imageView.image)*/
        imagePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if editMode {
            delegate!.deleteNote(note: selectedNote!)
           
        }
        guard noteTextView.text != "" || imageView.image != nil else {return}
        delegate!.updateNote(with: titleTextView.text! , with: (imageView.image?.pngData())! , with : noteTextView.text!)
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
