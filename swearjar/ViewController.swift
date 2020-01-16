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


class ViewController: UIViewController, SpeechEventListener, PipelineDelegate, TextToSpeechDelegate {
    var config:SpeechConfiguration? = nil
    var tts:TextToSpeech? = nil
    var moneyInSwearJar:Int = 0
    var repremandIndex:Int = 0
    var bombSoundEffect: AVAudioPlayer?
    
    @IBOutlet weak var swearJarCountDisplay: UILabel!
    
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
        config?.wakewords = "bitch,shirt,farts,fart,biff,spaghettios,fork,fuck,damn,crap,poop,mother forker,bull shirt,shirt balls,bench,ash,ass,cock,cork,deck,dick,gosh,crud,turd,shit"
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
       print("USER TEXT<><><><><><")
       tts?.speak(TextToSpeechInput("You hit did recognize"))
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
        
        let path = Bundle.main.path(forResource: "bell.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            bombSoundEffect = try AVAudioPlayer(contentsOf: url)
        } catch {
            // couldn't load file :(
        }
        print("LOADED<><><><><><><><><><><><")
        pipeline.start()
    }
    
   func deactivate() {
       self.pipeline.deactivate()
   }

   let repremands = ["You said a bad word. Put a dollar in the swear jar.", "Oh no you didn't!", "Do you kiss your mother with that mouth?"]
    
    func activate() {
        print("SPEECH ACTIVATED<><><><><<>")
        
        bombSoundEffect?.play()
        moneyInSwearJar = moneyInSwearJar + 1
        let dollar = moneyInSwearJar == 1 ? "dollar" : "dollars"
        let repremand = repremands[repremandIndex] + "There is now \(moneyInSwearJar) \(dollar) in the swear jar."
        repremandIndex = repremandIndex == repremands.count - 1 ? 0 : repremandIndex + 1
        print(repremand)
        tts?.speak(TextToSpeechInput(repremand))
        swearJarCountDisplay.text = "$\(moneyInSwearJar).00"
        pipeline.stop()
        pipeline.start()
    }

}

