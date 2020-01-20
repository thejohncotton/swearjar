//
//  ViewController.swift
//  swearjar
//
//  Created by John Cotton on 1/14/20.
//  Copyright © 2020 John Cotton. All rights reserved.
//

import UIKit

import Spokestack
import AVFoundation
import SAConfettiView


class ViewController: UIViewController, SpeechEventListener, PipelineDelegate, TextToSpeechDelegate {
    var speechConfig: SpeechConfiguration? = nil
    var tts: TextToSpeech? = nil
    var moneyInSwearJar: Int = 0
    var reprimandIndex: Int = 0
    var bellSoundEffect: AVAudioPlayer?
    let reprimands = ["You said a bad word. Put a dollar in the swear jar.", "Oh no you didn't!", "Do you kiss your mother with that mouth?"]
    var confettiView: SAConfettiView!
    
    
    
    lazy private var pipeline: SpeechPipeline = {
        speechConfig?.wakewords = "bitch,shirt,farts,fart,biff,spaghettios,fork,fuck,damn,crap,poop,mother forker,bull shirt,shirt balls,bench,ash,ass,cock,cork,deck,dick,gosh,crud,turd,shit, javascript,dang,dear"
        return SpeechPipeline(SpeechProcessors.appleSpeech.processor,
                              speechConfiguration: speechConfig!,
        speechDelegate: self,
        wakewordService: SpeechProcessors.appleWakeword.processor,
        pipelineDelegate: self)
    }()
    
    @IBOutlet weak var swearJarCountDisplay: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize Confetti View Class
        confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView!.type = .confetti
        confettiView!.colors = [UIColor.red, UIColor.green, UIColor.blue]
        confettiView!.intensity = 0.75
        self.view.addSubview(confettiView!)
        self.view.bringSubviewToFront(confettiView)
        speechConfig = SpeechConfiguration()
        // Turn this on for tracing
        //speechConfig!.tracing = .DEBUG

        do {
            tts = try TextToSpeech(configuration: speechConfig!)
        } catch let error {
            print("error initializing text to speech")
            print(error)
        }
        // Bell Sound Effect
        let path = Bundle.main.path(forResource: "bell.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            bellSoundEffect = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("error creating AVAudioPlayer")
        }
        
        pipeline.start()

    }
    
    
    // SpeechEventListener functions
    
    func activate() {
        moneyInSwearJar = moneyInSwearJar + 1
        bellSoundEffect!.play()
        confettiView!.startConfetti()
        let dollar = moneyInSwearJar == 1 ? "dollar" : "dollars"
        let reprimand = reprimands[reprimandIndex] + "There is now \(moneyInSwearJar) \(dollar) in the swear jar."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.reprimandIndex = self.reprimandIndex == self.reprimands.count - 1 ? 0 : self.reprimandIndex + 1
        
            self.tts?.speak(TextToSpeechInput(reprimand))
        
            self.swearJarCountDisplay.text = "$\(self.moneyInSwearJar).00"
        }
        self.pipeline.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.pipeline.start()
            self.confettiView!.stopConfetti()
        }
    }
    
    func deactivate() {
         self.pipeline.deactivate()
    }
    
    func didRecognize(_ result: SpeechContext) {
        // commented out for performance
//      let userText = result.transcript
//
//      if userText.range(of: "(?i)start",
//                        options: .regularExpression) != nil {
//          // start the timer and change the UI accordingly
//          return
//      }
//      if userText.range(of: "(?i)stop",
//                        options: .regularExpression) != nil {
//          // stop the timer and change the UI accordingly
//          return
//      }
//      if userText.range(of: "(?i)reset|start over",
//                        options: .regularExpression) != nil {
//          // reset the timer and change the UI accordingly
//          return
//      }
    }
    
    func didError(_ error: Error) {}
    func didTrace(_ trace: String) {}
    func didTimeout() {}
    
    // PipelineDelegate functions
    
    func didInit() {}
    func didStart() {}
    func didStop() {}
    func setupFailed(_ error: String) {}
    
    // TextToSpeechDelegate functions

    func success(result: TextToSpeechResult) {}
    func failure(error: Error) {}
    func didBeginSpeaking() {}
    func didFinishSpeaking() {}
}

