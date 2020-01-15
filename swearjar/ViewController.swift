//
//  ViewController.swift
//  swearjar
//
//  Created by John Cotton on 1/14/20.
//  Copyright © 2020 John Cotton. All rights reserved.
//

import UIKit
import Spokestack


class ViewController: UIViewController, SpeechEventListener, PipelineDelegate, TextToSpeechDelegate {
    var config:SpeechConfiguration? = nil
    var tts:TextToSpeech? = nil
    
    func success(result: TextToSpeechResult) {
    
    }
    
    func failure(error: Error) {
        
    }
    
    func didBeginSpeaking() {
    
    }
    
    func didFinishSpeaking() {
    
    }
    
    func didInit() {
        
    }
    
    func didStart() {
        
    }
    
    func didStop() {
        
    }
    
    func setupFailed(_ error: String) {
        
    }
    

    lazy private var pipeline: SpeechPipeline = {
        config?.wakewords = "bitch,shirt,farts,fart,biff,spaghettios,fork,fuck,damn"
        return SpeechPipeline(SpeechProcessors.appleSpeech.processor,
                              speechConfiguration: config!,
        speechDelegate: self,
        wakewordService: SpeechProcessors.appleWakeword.processor,
        pipelineDelegate: self)
    }()


    func didError(_ error: Error) {
     print("ERRORING<><><><")
     print(error)
   }
   
   func didTrace(_ trace: String) {
     print("<><><><TRACING")
     print(trace)
   }
   
   func didRecognize(_ result: SpeechContext) {
       let userText = result.transcript
       print(userText)

       if userText.range(of: "(?i)start",
                         options: .regularExpression) != nil {
           // start the timer and change the UI accordingly
           return
       }
       if userText.range(of: "(?i)stop",
                         options: .regularExpression) != nil {
           // stop the timer and change the UI accordingly
           return
       }
       if userText.range(of: "(?i)reset|start over",
                         options: .regularExpression) != nil {
           // reset the timer and change the UI accordingly
           return
       }
   }
   
   func didTimeout() {
       
   }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        config = SpeechConfiguration()
        config!.tracing = .DEBUG

        do {
            tts = try TextToSpeech(configuration: config!)
        } catch let error {
            print("error initializing text to speech")
            print(error)
        }
        print("LOADED<><><><><><><><><><><><")
        pipeline.start()
    }
    
   func deactivate() {
       self.pipeline.deactivate()
   }

    
    func activate() {
        print("SPEECH ACTIVATED<><><><><<>")
        tts?.speak(TextToSpeechInput("Yo mama"))
        pipeline.stop()
        pipeline.start()
    }

    
    
    

}

