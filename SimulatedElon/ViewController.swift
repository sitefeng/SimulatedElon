//
//  ViewController.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/17/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import ApiAI
import AudioToolbox
import AVFoundation
import SpeechKit
import Speech

enum ElonStatus {
    case Waiting
    case Talking
    case Listening
}

class ViewController: UIViewController, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    
    // Constants
    let startingAudioIds = ["569", "570", "593"]
    let connectingAudioIds = ["544", "545", "546", "547", "548", "553", "561", "566", "582", "584", "595", "596", "5110", "23", "77", "78", "717"]
    
    // Logic
    private var currentStatus: ElonStatus = .Waiting
    private var currentAudioId: String?
    private var audioPlayerInitialized = false
    private var currentMainAudios: [String] = []
    private var currentBackupAudios: [String] = []
    private var currentAudioIndex: Int = 0
    
    private var bubbleTexts: [String] = []
    
    private let totalImages: Int = 60
    private var currentImageIndex: Int = 1
    private var gestureRecStartingIndex: Int = 1
    
    // Animations
    private let mouthImages: Int = 8
    private var mouthImageIndex: Int = 0
    private var mouthAnimationSpeed = 0.1
    
    private var isElonRotating = false
    
    var lowPassResults: Float = 0
    
    var audioPlayer = AVAudioPlayer()
    var apiAi: ApiAI
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var mouthTimer: Timer?
    var microphoneTimer: Timer?
    var bubbleTimer: Timer?
    var autoStopTimer: Timer?
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var elonImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var chatBubbleContainer: UIView!
    var chatBubble: ChatBubbleView = ChatBubbleView.instanceFromNib()
    @IBOutlet weak var orangeDotImageView: UIImageView!
    
    @IBOutlet weak var dictationTextLabel: UILabel!
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.apiAi = ApiAI.shared()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.apiAi = ApiAI.shared()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuestionAsked(notif:)), name: SimulatedElonDidAskQuestionNotification, object: nil)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        // Gesture Recs
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(backgroundViewSwipped(recognizer:)))
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(elonImageTapped))
        elonImageView.addGestureRecognizer(tapRec)
        elonImageView.addGestureRecognizer(panRec)
        
        // Setup Views
        chatBubbleContainer.backgroundColor = UIColor.clear
        chatBubbleContainer.addSubview(chatBubble)
        chatBubble.autoPinEdgesToSuperviewEdges()
        
        self.bubbleTexts = ["Nice to meet you! I am Simulated Elon.",
                            "Tap the microphone button to ask a question, tap on my head to stop the audio at any time.",
                            "What do you wanna talk about today?"]
        self.displayBubbleTextsSequentially()
        
        dictationTextLabel.text = "Tap on the microphone to begin..."
        
        elonImageView.layer.shadowRadius = 30
        elonImageView.layer.shadowColor = UIColor.black.cgColor
        elonImageView.layer.shadowOffset = CGSize(width: 16, height: 16)
        elonImageView.layer.shadowOpacity = 0.8
        
        orangeDotImageView.alpha = 0
        
        
        // Start animations
        self.startBlinkAnimations()
        self.startMouthAnimations()
        
        // Play Intro Audio
//        playAudioFileWithId(audioFileId: "")
    }
    
    
    func displayBubbleTextsSequentially() {
        var bubbleDuration: TimeInterval = 5.0
        for i in 0..<self.bubbleTexts.count {
            let bubbleText = self.bubbleTexts[i]
            let bubbleDelay = Double(i) * bubbleDuration
            if (i == self.bubbleTexts.count-1) {
                bubbleDuration = 8
            }
            Timer.scheduledTimer(withTimeInterval: bubbleDelay, repeats: false, block: { (timer) in
                self.chatBubble.showAnimatedBubble(text: bubbleText, duration: bubbleDuration)
            })
        }
    }
    
    func recognize() {
        if (currentStatus == .Listening) { return }
        currentStatus = .Listening
        
        self.startMicrophoneAnimations()
        
        // Start listening to the user.
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryRecord)
        try! audioSession.setMode(AVAudioSessionModeMeasurement)
        try! audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.dictationTextLabel.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                UIView.animate(withDuration: 0.5, animations: {
                    self.dictationTextLabel.alpha = 1.0
                });
                
                if self.autoStopTimer != nil {
                    self.autoStopTimer?.invalidate()
                    self.autoStopTimer = nil
                }
                self.autoStopTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.autoStopTimerCallback), userInfo: nil, repeats: false)
                
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.currentStatus = .Waiting
                self.stopMicrophoneAnimations()
                
                self.sendDialogflowRequest(requestString: self.dictationTextLabel.text ?? "")
            }

        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try! audioEngine.start()
        
    }
    
    @objc func autoStopTimerCallback() {
        autoStopTimer = nil
        self.stopRecording()
    }
    
    // Used to manually triggering stop, not stop handler
    func stopRecording() {
        recognitionRequest?.endAudio()
 
        // The rest are handled within the recognition request callback block
    }
    
    
    private func playAudioFileWithId(audioFileId: String) {

        if (self.currentAudioId == audioFileId) { return }
        
        if (self.audioPlayerInitialized) {
            self.audioPlayer.stop()
        }
        self.audioPlayerInitialized = true
        
        let audioFilePathOrNil = Bundle.main.path(forResource: "\(audioFileId)-music", ofType: "mp3")
        if let audioFilePath = audioFilePathOrNil {
            let audioFileURL = URL(fileURLWithPath: audioFilePath)
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL, fileTypeHint: "mp3")
            } catch {
                print("audio player not initialized")
            }
            
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            audioPlayer.volume = 1
            audioPlayer.delegate = self
            audioPlayer.play()
            
            currentStatus = .Talking;
        } else {
            print("Audio file not found: \(audioFileId)")
        }
    }
    
    func startPlayingAudioSequence() {
        currentAudioIndex = 0
        if (currentMainAudios.count > 0) {
            playAudioFileWithId(audioFileId: currentMainAudios[currentAudioIndex])
        }
    }
    
    private func sendTestDialogflowRequest() {
        sendDialogflowRequest(requestString: "How long does it take to get to mars?")
    }
    
    private func sendDialogflowRequest(requestString: String) {
        let request = self.apiAi.textRequest()
        request?.query = [requestString]
        request?.setCompletionBlockSuccess({ (request, responseRaw) in
            let response = responseRaw as! NSDictionary
            let result = response["result"] as! NSDictionary
            let fulfillment = result["fulfillment"] as! NSDictionary
            
            print("--> ApiAI Response \(fulfillment)")
            
            // Set current audio
            self.currentMainAudios = []
            self.currentBackupAudios = []
            if let data = fulfillment["data"] as? NSDictionary {
                
                if let mainAudioIds = data["audio"] as? Array<String> {
                    self.currentMainAudios = [];
                    
                    for mainAudio in mainAudioIds {
                        self.currentMainAudios.append(mainAudio)
                        self.currentMainAudios.append(self.getRandomItemFromArray(array: self.connectingAudioIds))
                    }
                    
                    if self.currentMainAudios.count > 1 {
                        self.currentMainAudios.remove(at: self.currentMainAudios.count-1)
                    }
                }
                
                if let backupAudioIds = data["audioBackup"] as? Array<String> {
                    for backupAudio in backupAudioIds {
                        self.currentBackupAudios.append(backupAudio)
                    }
                }
                
                // Start playing
                self.startPlayingAudioSequence()
                
                // Fill bubble texts
                if let displayText = fulfillment["displayText"] as? String, displayText != "" {
                    self.bubbleTexts = [displayText]
                    self.displayBubbleTextsSequentially()
                }
                
                // if exists, "bubbleTexts" data overwrites default "displayText" data
                if let inputBubbleTexts = data["bubbleTexts"] as? Array<String>, inputBubbleTexts.count > 0 {
                    self.bubbleTexts = inputBubbleTexts
                    self.displayBubbleTextsSequentially()
                }
                
                // Perform action
                if let inputAction = data["action"] as? String {
                    self.performRequestedAction(action: inputAction)
                }
                
            } else { // No data field
                
                // Set basic text bubble
                if let displayText = fulfillment["displayText"] as? String, displayText != "" {
                    self.bubbleTexts = [displayText]
                    self.displayBubbleTextsSequentially()
                } else {
                    // Play I don't know audio
                    if (arc4random() % 10 > 1) {
                        self.currentMainAudios = [self.getRandomItemFromArray(array: ["735", "738"])]
                        self.startPlayingAudioSequence()
                    }
                    
                    self.bubbleTexts = [self.getRandomItemFromArray(array: ["uhh..", "uhh.. no idea", "Not sure..", "I'm not not quite sure"])]
                    self.displayBubbleTextsSequentially()
                }
                
            }
            
            
        }, failure: { (request, error) in
            print("Error \(error?.localizedDescription)")
        })
        self.apiAi.enqueue(request)
    }
    
    // MARK - Actions
    func performRequestedAction(action: String) {
        switch(action) {
        case "open_mouth":
            self.playOpenMouthAnimation()
        case "close_eyes":
            self.playCloseEyesAnimation()
        default:
            print("hi")
        }
    }
    
    
    // MARK - Animations
    func playOpenMouthAnimation() {
        self.elonImageView.image = UIImage(named: "surprise")
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            self.elonImageView.image = UIImage(named: "mouth4")
        }
        Timer.scheduledTimer(withTimeInterval: 0.55, repeats: false) { (timer) in
            self.elonImageView.image = UIImage(named: "mouth3")
        }
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            self.elonImageView.image = UIImage(named: "mouth2")
        }
        Timer.scheduledTimer(withTimeInterval: 0.65, repeats: false) { (timer) in
            self.elonImageView.image = UIImage(named: "mouth1")
        }
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { (timer) in
            self.elonImageView.image = UIImage(named: "1")
        }
    }
    
    func playCloseEyesAnimation() {
        self.elonImageView.image = UIImage(named: "blink.png")
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
            OperationQueue.main.addOperation {
                self.elonImageView.image = UIImage(named: "1.png")
            }
        })
    }
    
    func startBlinkAnimations() {
        let waitInterval = 0.5 + Double(arc4random() % 6)
        Timer.scheduledTimer(withTimeInterval: waitInterval, repeats: false, block: { (timer) in
            if (!self.isElonRotating) {
                OperationQueue.main.addOperation {
                    self.elonImageView.image = UIImage(named: "blink.png")
                }
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                    OperationQueue.main.addOperation {
                        self.elonImageView.image = UIImage(named: "1.png")
                    }
                })
            }
            
            self.startBlinkAnimations()
        })
    }
    
    func startMouthAnimations() {
        // Mouth speed from 0.02 to 0.2
        // Change speed for every whole mouth movement cycle
        if (self.mouthImageIndex == 0) {
            let waitInterval = 0.02 + Double(arc4random() % 10) / 100
            self.mouthAnimationSpeed = waitInterval
            if (arc4random() % 100 > 50) {
                self.mouthTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
                    self.startMouthAnimations()
                })
                return
            }
        }
        
        self.mouthTimer = Timer.scheduledTimer(withTimeInterval: self.mouthAnimationSpeed, repeats: false, block: { (timer) in
            self.moveMouthIncrementally();
            self.startMouthAnimations()
        })
    }
    
    func moveMouthIncrementally() {
        if (self.currentStatus == ElonStatus.Talking) {
            OperationQueue.main.addOperation {
                self.mouthImageIndex = (self.mouthImageIndex + 1) % self.mouthImages
                let elonImage = UIImage(named: "mouth\(self.mouthImageIndex).png")
                self.elonImageView.image = elonImage
            }
        }
    }
    
    func startMicrophoneAnimations() {
        
        self.requestButton.setImage(UIImage(named: "microphoneActivated.png"), for: .normal)
        self.microphoneTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (timer) in
            UIView.animate(withDuration: 0.04, animations: {
                if self.audioEngine.isRunning {
                    self.orangeDotImageView.alpha = 0.7
                } else {
                    self.orangeDotImageView.alpha = 0
                }
            })
        }
    }
    
    func stopMicrophoneAnimations() {
        
        self.orangeDotImageView.alpha = 0
        self.requestButton.setImage(UIImage(named: "microphone.png"), for: .normal)
        self.microphoneTimer?.invalidate()
    }
    
    
    // MARK - Callbacks

    @IBAction func requestButtonTapped(_ sender: Any) {
        if currentStatus == .Listening {
            stopRecording()
        } else {
            if currentStatus == .Talking {
                audioPlayer.stop()
            }
            
            if (SFSpeechRecognizer.authorizationStatus() == .notDetermined) {
                SFSpeechRecognizer.requestAuthorization({ (status) in
                    if status == .authorized {
                        self.recognize()
                    }
                })
            }
            
            if (SFSpeechRecognizer.authorizationStatus() == .authorized) {
                recognize()
            } else if SFSpeechRecognizer.authorizationStatus() == .denied {
                let alertController = UIAlertController(title: "Speech permission not enabled", message: "Please enable speech in Settings for this app. Please contact us if this issue persists", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            // Fade out previous dictation text
            UIView.animate(withDuration: 0.5, animations: {
                self.dictationTextLabel.alpha = 0.0
            }, completion: { _ in
                self.dictationTextLabel.text = ""
            })
        }
    }
    
    @objc func elonImageTapped() {
        self.playOpenMouthAnimation()
        
        if currentStatus == .Talking {
            currentStatus = .Waiting
            audioPlayer.stop()
        }
        
        if arc4random() % 10 < 1 {
            self.bubbleTexts = [getRandomItemFromArray(array: ["I don't like people touching my face", "Ahh", "Ooo"])]
            self.displayBubbleTextsSequentially()
        }
       
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let settingsVC = SettingsViewController(nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func questionButtonTapped(_ sender: Any) {
        let questionVC = QuestionViewController(nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: questionVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    // NotificationCenter handlers
    @objc func notificationQuestionAsked(notif: Notification) {
        if let userInfo = notif.userInfo, let question = userInfo["question"] as? String {
            self.dictationTextLabel.text = question
            self.sendDialogflowRequest(requestString: self.dictationTextLabel.text ?? "")
        }
    }
    
    
    // MARK - AudioDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentStatus = .Waiting
        
        self.currentAudioIndex += 1
        if self.currentAudioIndex < self.currentMainAudios.count {
    
            // play main audio
            playAudioFileWithId(audioFileId: currentMainAudios[currentAudioIndex])
        } else if self.currentAudioIndex == self.currentMainAudios.count {
            
            // start playing one backup audio at the end
            if (self.currentBackupAudios.count > 0) {
                Timer.scheduledTimer(withTimeInterval: 1 + Double(arc4random_uniform(5)), repeats: false, block: { (timer) in
                    let randomBackupIndex = Int(arc4random_uniform(UInt32(self.currentBackupAudios.count)))
                    self.playAudioFileWithId(audioFileId: self.currentBackupAudios[randomBackupIndex])
                })
            }
        } else {
            // Finished
        }
    }
    
    
    // GestureRecognizerDelegate
    @objc func backgroundViewSwipped(recognizer: UIPanGestureRecognizer) {

        let translation = recognizer.translation(in: self.backgroundView)
        
        if (recognizer.state == .began) {
            gestureRecStartingIndex = self.currentImageIndex
            isElonRotating = true
        } else if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            isElonRotating = false
        }
    
        let nextIndex = self.gestureRecStartingIndex - Int(translation.x / 2)
        self.currentImageIndex = min(max(0, (nextIndex + self.totalImages) % self.totalImages), 60)
        
        let newImage = UIImage(named: "\(self.currentImageIndex).png")
        self.elonImageView.image = newImage
        
        // Complain about spinning
        if self.currentImageIndex == 30 && arc4random() % 10 < 2 {
            self.bubbleTexts = [self.getRandomItemFromArray(array: ["Stop spinning my head", "Don't spin my head anymore"]) , self.getRandomItemFromArray(array: ["It's making me dizzy", "I'm getting dizzy", "I'm not feeling too well after spinning", "I'm not feeling too well"])]
            self.displayBubbleTextsSequentially()
        }
    }
    
    // Helpers
    func getRandomItemFromArray<T>(array: [T]) -> T {
        let index = Int(arc4random_uniform(UInt32(array.count)))
        return array[index]
    }

    
}

