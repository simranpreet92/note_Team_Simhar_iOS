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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var audioLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var audioPlayButton: UIButton!
    
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
    //playing audio
    var audioPlayer  :AVAudioPlayer!
    
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
        audioFile = noteChosen?.audio ?? ""
        audioLabel.text =  audioFile
        if noteChosen?.image == nil
        {
            print("No image")
            imageView.image = UIImage(named: "n3")
        }
        else
        {
            print("image exists")
            imageView.image = UIImage(data: (noteChosen?.image)!)
        }
        self.setRecordSession()
        audioPlayButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    //firstly, user's current location is displayed on map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    let userLocation = locations[0]
    
    let Userlatitude = userLocation.coordinate.latitude
    let Userlongitude = userLocation.coordinate.longitude
        userCurrentLocation = CLLocationCoordinate2D(latitude: Userlatitude, longitude: Userlongitude)
        // calling the function locationManager here
        print(userCurrentLocation)
    displayLocation(latitude: Userlatitude, longitude: Userlongitude, title: "your Current location", subtitle: "You are currently here")
        
     
    
    }

    //MARK: - display user location method
    
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        mapView.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
       
    }

    @IBAction func pictureBtn(_ sender: UITapGestureRecognizer) {
        imagePicker.delegate = self
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
  
    @objc func playTapped()
     {
        
        let audioUrl = getDocumentsDirectory().appendingPathComponent(audioFile)
        do
         {
             audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
             audioPlayer.play()
         }catch
         {
             print(error)
         }
     }
   
 
   
    
    //MARK:- Intance Methods

    @IBAction func viewLocation(_ sender: UIButton) {
        // we define the accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // we assign the delegate property of the location manager to be this class
         locationManager.delegate = self
       
         
         // rquest for the permission to access the location
         locationManager.requestWhenInUseAuthorization()
         //locationManager.requestAlwaysAuthorization()/
         
         // start updating the location
         locationManager.startUpdatingLocation()
         
         // 1st step is to define latitude and longitude
        // 1st step is to define latitude and longitude
         mapView.delegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        if editNote {
            delegate!.deleteSelectedNote(note: noteChosen!)
           
        }
        guard noteTextView.text != "" || imageView.image != nil else {return}
        delegate!.updateSelectedNote(with: titleTextView.text! , with: (imageView.image?.pngData())! , with : noteTextView.text! , with : audioFile , with : userCurrentLocationLat , with : userCurrentLocationLong)
    }
}
