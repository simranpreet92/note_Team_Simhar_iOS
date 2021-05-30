//
//  singleNoteVC.swift
//  note_team_Simhar_iOS
//
//  Created by Simranpreet kaur on 2021-05-28.
//

import UIKit
import AVFoundation
class singleNoteVC: UIViewController , UINavigationControllerDelegate ,UIImagePickerControllerDelegate, AVAudioRecorderDelegate {
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    var audioFile = ""
    let imagePicker = UIImagePickerController()
    
    //recording audio
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
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
        audioFile = noteChosen?.title ?? ""
        imagePicker.delegate = self
        self.setRecordSession()
        
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        if editNote {
            delegate!.deleteSelectedNote(note: noteChosen!)
           
        }
        guard noteTextView.text != "" || imageView.image != nil else {return}
        delegate!.updateSelectedNote(with: titleTextView.text! , with: (imageView.image?.pngData())! , with : noteTextView.text! , with : audioFile )
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
    
    func setRecordSession()
    {
        //getting Microphone permission
        recordingSession = AVAudioSession.sharedInstance()
        do{
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){ [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed{
                        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
                    }
                    else {
                        print("error")
                    }
                }
            }
        }catch {
            print(error)
        }

    }
    
    func startRecording ()
    {
        audioFile = String(Int.random(in: 1...100000)) + "recording.m4a"
        let audioFilePath = getDocumentsDirectory().appendingPathComponent(audioFile)
        print("path" ,audioFilePath)
        let settings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 12000,
            AVNumberOfChannelsKey : 1,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordButton.setImage(UIImage.init(systemName: "mic.circle.fill"), for: .normal)

        }catch {
            finishRecording(false)
        }
    }
    func finishRecording(_ success: Bool )
    {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setImage(UIImage.init(systemName: "mic.circle"), for: .normal)
            }
        else{
            print("error")
        }
        
        
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
   @objc func recordTapped()
    {
    if audioRecorder == nil {
        startRecording()
    }else
    {
        finishRecording(true)
    }
    }
  
 
   
}
