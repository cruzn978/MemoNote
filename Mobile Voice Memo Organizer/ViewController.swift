//
//  ViewController.swift
//  Mobile Voice Memo Organizer
//
//  Created by Alaska Day on 4/30/20.
//  Copyright © 2020 Alaska Day. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var recordBtn: UIButton!
    //so that we can "refresh the table"
    @IBOutlet weak var myTable: UITableView!
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var numOfRecordings = 0
    var currentFolder = Folder()
    var parentView = TableViewController()
    var selectedFolderIndex = 0
    
    @IBAction func record(_ sender: Any) //_ sender:UIButton referencing the button i.e. sender.setColor(.red) will change button color to red after click
    {
        let filename = "\(numOfRecordings).m4a"
        // check if we have an active recording aka we're not recording now
        if audioRecorder == nil {
            let filepath = getDirectory().appendingPathComponent(filename)
            let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey : 12000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue ]
            
            // start recording!!!
            do
            {
               
                audioRecorder = try AVAudioRecorder(url: filepath, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                recordBtn.setTitle("🔘", for: .normal)
            }
            catch
            {
                displayAlert(title: "Oops!", message: "Recording failed")
            }
        }
        else
        {
            // we're recording, stop the recording
            audioRecorder.stop()
            audioRecorder = nil
            
            // User Defaults is like local storage, the key values will persist after reopening app
            UserDefaults.standard.set(numOfRecordings, forKey: "myNumber")
            //append the recording to the recordingList in the currFold
            //instantiate a Recording struct
            var recording = Recording()
            recording.fileName = filename
            recording.name = "placeholder name" + filename
            currentFolder.recordingList.append(recording)
            //get curr Folder index in parentView
            //rewrite parentView.originalFolders[currFolderIndex] = currentFolder
            parentView.originalFolders[selectedFolderIndex] = currentFolder
            //refresh tableView after we've stopped recording
            //we have a new recording so to display all latest recordings,refresh tableView
            myTable.reloadData()
//            transcribeAudio(url: getDirectory().appendingPathComponent(filename))
            transcribeAudio(url: getDirectory().appendingPathComponent(filename))
            //get the last recording
            //set the transcript to transcribeAudio(url: getDirectory().appendingPathComponent(filename))
            recordBtn.setTitle("🔴", for: .normal)
            numOfRecordings += 1
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        requestTranscribePermissions()
        
        // need delegate and dataSource explicitly defined if not a TableViewController
        myTable.delegate = self
        myTable.dataSource = self
        
        //setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        // when launching app, check if there "myNumber" exists in UserDefaults, if so, set that value as CURRENT numOfRecordings (stored in UserDefaults)
        //
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int
        {
            numOfRecordings = number
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission
            {
                print("ACCEPTED")
            }
        }
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)
        var finalResult = ""
        // start recognition!
        recognizer?.recognitionTask(with: request) { (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }

            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                print(result.bestTranscription.formattedString)
                finalResult = result.bestTranscription.formattedString
                
                //have helperfunc(finalResult) => set transcript val to finalResult
                self.setTranscriptionValue(transcription: finalResult)
            }
        }
    }
    //MARK: TRANSCRIPTION FUNCTION
    func setTranscriptionValue(transcription: String) {
        currentFolder.recordingList[currentFolder.recordingList.count - 1].transcription = transcription
        print(currentFolder.recordingList.last)
    }

    //fxn that gets directory path where the recordings will be saved
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //fxn that displays alert
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // SETTING UP TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentFolder.recordingList.count
    }
    
    // define content at each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProto", for: indexPath)
        // how to access current row? indexPath.row
        // Set each cell text = names of Recordings
        
        cell.textLabel?.text = currentFolder.recordingList[indexPath.row].name
        return cell
    }
    
    // to play recording at cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // access cell number that the user tapped on (indexPath.row + 1)
        // saves it as a path to the recording
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        
        // play contents that is hidden/stored at that path
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }
        catch
        {
            
        }
    }
}

