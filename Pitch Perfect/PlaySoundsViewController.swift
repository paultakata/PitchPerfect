//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Paul Miller on 6/03/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    var timer: NSTimer?
    
    //MARK: - Overrides
    //MARK: View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathURL, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        audioFile = AVAudioFile(forReading: receivedAudio.filePathURL, error: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.alpha = 0.0
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Remove recorded audio when user leaves playback view, this prevents user's disk space filling up with old files.
        let fileManager = NSFileManager.defaultManager()
        var error: NSError?
        
        if fileManager.removeItemAtURL(receivedAudio.filePathURL!, error: &error) {
            println("Deleting file")
        } else {
            println("Remove failed: \(error!.localizedDescription)")
        }
    }
    
    //MARK: Other
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Interface Builder actions
    
    @IBAction func playSlowAudio(sender: UIButton) {
        
        stopAllAudio()
        playAudioWithVariableRate(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        
        stopAllAudio()
        playAudioWithVariableRate(2.0)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        
        stopAllAudio()
        playAudioWithVariablePitch(1200)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        
        stopAllAudio()
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        
        stopAllAudio()
        
        //Re-hide the stop button.
        UIView.animateWithDuration(0.4,
            animations: {self.stopButton.alpha = 0.0})
    }
    
    //MARK: - Helper functions
    
    func playAudioWithVariableRate(rate: Float) {
        
        //If timer relating to playAudioWithVariablePitch is running, invalidate it.
        //This prevents the stop button from behaving weirdly.
        if self.timer != nil {
            self.timer!.invalidate()
        }
        
        //Stop audioPlayer, then restart it with the new rate from the beginning of the audio file.
        audioPlayer.stop()
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
        
        //If it is playing, show the stop button.
        if (self.audioPlayer.playing) {
            UIView.animateWithDuration(0.4,
                animations: {self.stopButton.alpha = 1.0})
        }
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        
        //Reset audioPlayer and audioEngine before doing anything with them.
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        //Initialise audioPlayerNode and attach it to audioEngine.
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        //Create pitch changing effect unit, attach it to audioEngine.
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        //Create reverb effect unit, attach it to audioEngine.
        var reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.LargeRoom)
        reverbEffect.wetDryMix = 50
        audioEngine.attachNode(reverbEffect)
        
        //Connect audio player to the pitch effect, pitch effect to reverb effect, then reverb effect to output.
        audioEngine.connect(audioPlayerNode,
            to: changePitchEffect,
            format: nil)
        audioEngine.connect(changePitchEffect,
            to: reverbEffect,
            format: nil)
        audioEngine.connect(reverbEffect,
            to: audioEngine.outputNode,
            format: nil)
        
        //Prepare audioPlayerNode and audioEngine for playback, then play.
        audioPlayerNode.scheduleFile(audioFile,
            atTime: nil,
            completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
        
        //If it is playing, show the stop button for the duration of the sound file.
        if (self.audioPlayerNode.playing) {
            UIView.animateWithDuration(0.4,
                animations: {self.stopButton.alpha = 1.0})
            
            //The following timer makes the stop button hide again once the sound has finished playing.
            //If timer already exists, invalidate it then start a new one.
            if self.timer != nil {
                self.timer!.invalidate()
            }
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.audioPlayer.duration, target: self, selector: "stopButtonFade", userInfo: nil, repeats: false)
        }
    }
    
    func stopAllAudio() {
        
        //Check to see if audioPlayerNode has been initialised before trying to stop it.
        if ((audioPlayerNode) != nil) {
            audioPlayerNode.stop()
            audioEngine.stop()
            audioEngine.reset()
        }
        audioPlayer.stop()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        
        //Hide the stop button once AVAudioPlayer has finished playing.
        UIView.animateWithDuration(0.4, animations: {self.stopButton.alpha = 0.0})
    }
    
    func stopButtonFade() {
        UIView.animateWithDuration(0.4, animations: {self.stopButton.alpha = 0.0})
    }
}
