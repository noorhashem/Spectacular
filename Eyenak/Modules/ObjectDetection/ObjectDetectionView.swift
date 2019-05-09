//
//  ObjectDetectionView.swift
//  Eyenak
//
//  Created by Noor on 6/27/18.
//  Copyright © 2018 Noor. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Vision

class ObjectDetectionView: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var label: UILabel!
    var speaker = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.speak(text: "Tap to use object detection or swipe left for currency detection")
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

        picker.dismiss(animated: true, completion: nil)
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        detectObjectInImage(pickedImage)
    }

    func detectObjectInImage(_ image: UIImage) {

        let newImage = image.resize(toSize: CGSize(width: 224, height: 224), opaque: true, scale: 2.0)

        var pixelBuffer: CVPixelBuffer?
        if createPixelBufferForImage(&pixelBuffer, newImage) == kCVReturnSuccess {
            configurePixelBuffer(&pixelBuffer!, newImage)
            do {
                let predictionText = try Resnet50().prediction(image: pixelBuffer!).classLabel
                label.text = predictionText
                speak(text: predictionText)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    private func createPixelBufferForImage(_ pixelBuffer: inout CVPixelBuffer?, _ image: UIImage) -> CVReturn {
        return CVPixelBufferCreate(kCFAllocatorDefault,
                                   Int(image.size.width), Int(image.size.height),
                                   kCVPixelFormatType_32ARGB,
                                   [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary,
                                   &pixelBuffer)
    }

    private func configurePixelBuffer(_ pixelBuffer: inout CVPixelBuffer, _ newImage: UIImage) {

        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

        let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                width: Int(newImage.size.width),
                                height: Int(newImage.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speaker.speak(utterance)
    }
}
