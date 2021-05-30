//
//  singleNoteVC.swift
//  note_team_Simhar_iOS
//
//  Created by Simranpreet kaur on 2021-05-28.
//

import UIKit
import MapKit
import AVFoundation
class singleNoteVC: UIViewController , UINavigationControllerDelegate ,UIImagePickerControllerDelegate, AVAudioRecorderDelegate , CLLocationManagerDelegate, MKMapViewDelegate{
    @IBOutlet weak var locationBtn: UIButton!
  
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    // create location manager
    var locationManager = CLLocationManager()
    var userCurrentLocation : CLLocationCoordinate2D!
    var mRegion : MKCoordinateRegion!
    var audioFile = ""
    let imagePicker = UIImagePickerController()
    var userCurrentLocationLat = 0.0
    var userCurrentLocationLong = 0.0
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
        imageView.image = UIImage(data: (noteChosen?.image)!)
        imagePicker.delegate = self
        self.setRecordSession()
        // we assign the delegate property of the location manager to be this class
        
        
    }
    //MARK:- CLLocationManagerDelegate Methods

       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("3 entry")
           let mUserLocation:CLLocation = locations[0] as CLLocation

           let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
              mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        //print(mRegion)
       print(center)
         userCurrentLocationLat = center.latitude
       print(userCurrentLocationLat)
       // print(userCurrentLocationLat)
       
         userCurrentLocationLong = center.longitude
        print(userCurrentLocationLong)
        
        print("3 exit")
         //  mMapView.setRegion(mRegion, animated: true)
       }
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Error - locationManager: \(error.localizedDescription)")
       }
   //MARK:- Intance Methods

   func determineCurrentLocation() {
    print("2 entry")
       locationManager = CLLocationManager()
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       locationManager.requestAlwaysAuthorization()

       if CLLocationManager.locationServicesEnabled() {
           locationManager.startUpdatingLocation()
       }
    print("2 exit")
   }
    
    override func viewWillDisappear(_ animated: Bool) {
        if editNote {
            delegate!.deleteSelectedNote(note: noteChosen!)
           
        }
        guard noteTextView.text != "" || imageView.image != nil else {return}
        delegate!.updateSelectedNote(with: titleTextView.text! , with: (imageView.image?.pngData())! , with : noteTextView.text! , with : audioFile , with : userCurrentLocationLat , with : userCurrentLocationLong)
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
        
      //  print(imageInstance.image)
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
  
 
    @IBAction func userCurrentLocation(_ sender: UIButton) {
        locationManager.delegate = self
        
       
       print("1 entr")
       // call current location function
       determineCurrentLocation()
       print("latloc" , userCurrentLocationLat)
        print("longloc" , userCurrentLocationLong)
       
       
    }
    
    @IBAction func viewLocation(_ sender: UIButton) {
        
    }
}
