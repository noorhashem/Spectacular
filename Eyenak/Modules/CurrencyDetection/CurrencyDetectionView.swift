import UIKit
import AVFoundation

class CurrencyDetectionViewNoor: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var resultsTextView: UITextView!

    private lazy var modelManager = ModelInterpreterManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocalModel()
        self.speak(text: "Shake to use currency detection or swipe back to the right")
    }

    private func setUpLocalModel() {
        if !modelManager.setUpLocalModel(withName: "optimized_graph") {
            appendResults(text: "Failed to set up the local model.")
        }
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake {
            self.openCamera()
        }
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
        clearResults()
        picker.dismiss(animated: true, completion: nil)
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        updateImageView(with: pickedImage) {
            self.detectObjects()
        }
    }

    private func updateImageView(with image: UIImage, completion: @escaping () -> Void) {

        guard image.size.width > .ulpOfOne, image.size.height > .ulpOfOne else {
            self.imageView.image = image
            appendResults(text: "Failed to update image view because image has invalid size: \(image.size)")
            return
        }

        var scaleSize = CGSize.zero
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown, .unknown:
            scaleSize = CGSize(width: imageView.bounds.size.width, height: image.size.height * imageView.bounds.size.width / image.size.width)
        case .landscapeLeft, .landscapeRight:
            scaleSize = CGSize(width: image.size.width * imageView.bounds.size.height / image.size.height, height: imageView.bounds.size.height)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let scaledImage = image.scale(with: scaleSize, opaque: false, scale: image.scale)
            DispatchQueue.main.async {
                self.imageView.image = scaledImage ?? image
                completion()
            }
        }
    }

    func detectObjects() {

        clearResults()

        guard let image = imageView.image else {
            appendResults(text: "Image must not be nil.\n")
            return
        }

        appendResults(text: "Loading the local model...\n")

        guard modelManager.loadLocalModel() else {
            appendResults(text: "Failed to load the local model.")
            return
        }

        appendResults(text: resultsTextView.text + "Starting inference...\n")

        DispatchQueue.global(qos: .userInitiated).async {

            self.modelManager.detectObjects(in: self.modelManager.scaledImageData(from: image)) { (results, error) in
                guard error == nil, let results = results, !results.isEmpty else {
                    self.appendResults(text: "Inference error: \(error?.localizedDescription ?? "Failed to detect objects in image.")")
                    return
                }
                self.appendResults(text: self.describeSuccessResults(results))
            }
        }
    }

    private func describeSuccessResults(_ results: [(label: String, confidence: Float)]?) -> String {
        guard let results = results else {
            return "Failed to detect objects in image."
        }
        return results.reduce("") { (resultString, result) -> String in
            return resultString + "\(result.label): \(String(describing: result.confidence))\n"
        }
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }

    private func appendResults(text: String) {
        resultsTextView.text = "\(resultsTextView.text ?? "")\n" + text
    }

    private func clearResults() {
        resultsTextView.text = ""
    }
}
