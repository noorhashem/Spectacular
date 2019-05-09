///
//  TextDetectionView.swift
//  Eyenak
//
//  Created by Noor on 6/27/18.
//  Copyright © 2018 Noor. All rights reserved.
//

import UIKit
import FirebaseMLVision
import AVFoundation

class TextDetectionView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var label: UILabel!
    var speaker = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.speak(text: " Tap to use OCR or swipe left for object Detection ")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        speaker.stopSpeaking(at: AVSpeechBoundary.immediate)
    }

    @IBAction func didTap(_ sender: Any) {
        openCamera()
    }

    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        self.label.isHidden = true
        picker.dismiss(animated: true, completion: nil)
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        detectTextInImage(pickedImage)
    }

    private func detectTextInImage(_ image: UIImage) {

        let options = VisionCloudDetectorOptions()
        options.modelType = .latest

        let visionImage = VisionImage(image: image.resize(toWidth: 400.0, opaque: false, scale: 1.0))

        Vision
            .vision()
            .cloudTextDetector(options: options)
            .detect(in: visionImage) { (cloudText, error) in
                guard error == nil, let cloudText = cloudText else {
                    print(error.debugDescription)
                    return
                }

                self.handleDetectedText(cloudText)
        }
    }

    private func handleDetectedText(_ cloudText: VisionCloudText) {
        if let detectedText = cloudText.text {
            self.label.isHidden = false
            self.label.text = detectedText
            self.speak(text: detectedText)
        }
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speaker.speak(utterance)
    }
}
