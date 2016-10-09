//
//  VoiceSearchViewController.swift
//  SpeechSampleApp
//
//  Created by SpotHeroMatt on 9/30/16.
//  Copyright © 2016 Matthew Reed. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class VoiceSearchViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    var completion: ((String) -> ())?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false {
        didSet {
            let text = isRecording ? "Recording..." : "Record"
            recordButton.setTitle(text, for: .normal)
        }
    }
    
    let recognizer = SFSpeechRecognizer()
    let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()

        recognizer?.delegate = self
        
        // Do any additional setup after loading the view.
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.recordButton.isEnabled = true
                }
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordButtonPressed(_ sender: AnyObject) {
        isRecording = !isRecording
        
        guard isRecording else {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        guard let recognizer = recognizer else {
            return
        }
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.label.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
   
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let text = label.text else {
            return
        }
        
        completion?(text)
    }
}

extension VoiceSearchViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        recordButton.isEnabled = available
    }
}
