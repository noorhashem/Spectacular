//
//  IntroViewController.swift
//  Eyenak
//
//  Created by Noor on 6/27/18.
//  Copyright © 2018 Noor. All rights reserved.
//

import UIKit
import AVFoundation

class IntroViewController: UIViewController {

    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    var speaker = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        playGuidanceAudio()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        speaker.stopSpeaking(at: AVSpeechBoundary.immediate)
    }

    private func playGuidanceAudio() {
        let utterance = AVSpeechUtterance(string: "Hello, swipe left once for OCR, swipe twice for object detection, swipe thrice for currency")
        utterance.rate = 0.45
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speaker.speak(utterance)
    }
}
