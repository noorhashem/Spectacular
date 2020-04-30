# Spectacular, an iOS App with the brains to aid the visually impaired.

A Tensorflow / CoreML powered iOS app for aiding the visually impaired utilizing the power of machine learning.

An Object, Text and currency detectors using neural networks are the clockwork behind this app's functionalities.

<img src="/Screens/AppStoryboard.png" height = "400" align = "center">

Video for the app in operation 
https://www.youtube.com/watch?v=EdzhPSVAQDg

Tools Used: Swift, Firebase, Tensorflow, CoreML.

Navigation in the app relies on tapping and gestures acompanied by voice instructions.

It has 3 features : 
- Currency Detection
- General Objects Detection
- OCR Text Extraction
It detects those 3 types of inputs and voices their labels for the user.

1- For the currency detector, custom trained models using Tensorflow were used to detect currencies, trained on Nvidia GPUs , optimized and deployed on Mobile phones. the output of the Detection is then voiced over using text-to-speech engine.

2- For the General objects detector, a pre-trained model was used to detect common objects and voice them for the blind.

3- As for the third feature, it captures images of text from books, packages, signs and voices them over as well, the OCR feature is deployed on the cloud using Firebase ML Kit API functions.

Find Full Documentation series here : 
https://medium.com/@noorhashem/build-a-mobile-app-with-a-using-tensorflow-coreml-prt-1-6d0ca883e664



# Next Steps :

- [ ] Train a better accuracy compact model for currency detection
- [ ] User Testing
- [ ] Add Support for Arabic (and other languages) Text Extraction
- [ ] Add Support for other currencies (Suggestions are open)
- [ ] Add support for Color detection

