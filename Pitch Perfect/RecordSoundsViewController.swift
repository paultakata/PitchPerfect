//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Paul Miller on 5/03/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    //MARK: - Overrides
    //MARK: View methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Set user interface to be ready for recording.
        stopButton.alpha = 0.0
        pauseButton.alpha = 0.0
        recordingButton.enabled = true
        recordingLabel.text = "tap to record"
    }
    
    //MARK: Others
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "stopRecording") {
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            
            //Pass the recorded audio to PlaySoundsViewController for playback/processing.
            playSoundsVC.receivedAudio = data
        }
    }
    
    //MARK: - Interface Builder actions
    
    @IBAction func recordAudio(sender: UIButton) {
        
        //Show the stop and pause buttons and disable the record button.
        //Include fade animation to look nice.
        UIView.animateWithDuration(0.5,
            animations: {self.stopButton.alpha = 1.0; self.pauseButton.alpha = 1.0})
        recordingButton.enabled = false;
        
        //Get the save directory for the recorded audio.
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        
        //Create a unique filename for the recorded audio using the current date and time.
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)!
        
        //Create a new audio session.
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
        
        //Set up the audio recorder and start recording.
        audioRecorder = try? AVAudioRecorder(URL: filePath, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        //Inform the user that we are recording now.
        //Include fade animation to look nice.
        UIView.animateWithDuration(0.5,
            delay: 0,
            options: .CurveEaseIn,
            animations: {self.recordingLabel.alpha = 0.0},
            completion: nil)
        
        recordingLabel.text = "recording"
        
        UIView.animateWithDuration(0.5,
            delay: 0,
            options: .CurveEaseOut,
            animations: {self.recordingLabel.alpha = 1.0},
            completion: nil)
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        
        //Stop recording and deactivate the audio session.
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
        
        recordingButton.enabled = true;
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        
        if (audioRecorder.recording) {
            audioRecorder.pause()
            
            //Change recordingLabel to "paused". Keep it flashing to remind user.
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: .CurveEaseIn,
                animations: {self.recordingLabel.alpha = 0.0},
                completion: nil)
            recordingLabel.text = "paused"
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: [.Autoreverse, .Repeat],
                animations: {self.recordingLabel.alpha = 1.0},
                completion: nil)
        } else {
            audioRecorder.record()
            
            //Change recordingLabel back to "recording".
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: [.CurveEaseIn, .OverrideInheritedDuration],
                animations: {self.recordingLabel.alpha = 0.0},
                completion: nil)
            recordingLabel.text = "recording"
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: .CurveEaseOut,
                animations: {self.recordingLabel.alpha = 1.0},
                completion: nil)
        }
    }
    
    //MARK: - Audio method
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        //If recording was successful,
        if (flag) {
            //get the new audio file and pass it to PlaySoundsViewController with the segue.
            recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
            //Or, stay on the same screen and reset the buttons.
        } else {
            print("Recording was not successful")
            recordingButton.enabled = true
            stopButton.alpha = 0.0
        }
    }
}
