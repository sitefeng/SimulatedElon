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

enum ElonStatus {
    case Waiting
    case Talking
    case Listening
}

class ViewController: UIViewController, AVAudioPlayerDelegate, SKTransactionDelegate, UIGestureRecognizerDelegate {
    
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
    
    private let totalImages: Int = 60
    private var currentImageIndex: Int = 1
    private var gestureRecStartingIndex: Int = 1
    
    // Animations
    private let mouthImages: Int = 8
    private var mouthImageIndex: Int = 0
    private var mouthAnimationSpeed = 0.1
    
    var audioPlayer = AVAudioPlayer()
    var apiAi: ApiAI
    var skSession:SKSession?
    var skTransaction:SKTransaction?
    var mouthTimer: Timer?
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var elonImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var orangeDotImageView: UIImageView!
    @IBOutlet weak var bubbleLabel: UILabel!
    
    
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
        skSession = SKSession(url: URL(string: SKSServerUrl), appToken: SKSAppKey)
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(backgroundViewSwipped(recognizer:)))
        panRec.delegate = self
        backgroundView.addGestureRecognizer(panRec)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("Audio Session set category Failed")
        }
        
        elonImageView.layer.shadowRadius = 30
        elonImageView.layer.shadowColor = UIColor.black.cgColor
        elonImageView.layer.shadowOffset = CGSize(width: 16, height: 16)
        elonImageView.layer.shadowOpacity = 0.8
        
        // Start animations
        self.startBlinkAnimations()
        self.startMouthAnimations()
        
        // Play Audio
        playAudioFileWithId(audioFileId: "729")
    }
    
    func recognize() {
        if (currentStatus == .Listening) { return }
        currentStatus = .Listening
        
        // Start listening to the user.
        let recognitionType = SKTransactionSpeechTypeDictation
        let endpointer = SKTransactionEndOfSpeechDetection.short
        let language = SKSLanguage
        
        let options = NSMutableDictionary()
        
        // If progressive results
        options.setValue(SKTransactionResultDeliveryProgressive, forKey: SKTransactionResultDeliveryKey);
        
        skTransaction = skSession!.recognize(withType: recognitionType,
                                             detection: endpointer,
                                             language: language,
                                             options: nil,
                                             delegate: self)
    }
    
    func stopRecording() {
        currentStatus = .Waiting
        skTransaction!.stopRecording()
    }
    
    func cancelRecording() {
        currentStatus = .Waiting
        skTransaction!.cancel()
    }
    
    private func playAudioFileWithId(audioFileId: String) {

        if (self.currentAudioId == audioFileId) { return }
        
        if (self.audioPlayerInitialized) {
            self.audioPlayer.stop()
        }
        self.audioPlayerInitialized = true
        
        let audioFilePathOrNil = Bundle.main.path(forResource: audioFileId, ofType: "wav")
        if let audioFilePath = audioFilePathOrNil {
            let audioFileURL = URL(fileURLWithPath: audioFilePath)
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL, fileTypeHint: "wav")
            } catch {
                print("audio player not initialized")
            }
            
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
        playAudioFileWithId(audioFileId: currentMainAudios[currentAudioIndex])
    }
    
    private func sendTestDialogflowRequest() {
        sendDialogflowRequest(requestString: "How long does it take to get to mars?")
    }
    
    private func sendDialogflowRequest(requestString: String) {
        let request = self.apiAi.textRequest()
        request?.query = [requestString]
        request?.setCompletionBlockSuccess({ (request, responseRaw) in
//            print("response \(responseRaw!)")
            let response = responseRaw as! NSDictionary
            let result = response["result"] as! NSDictionary
            let fulfillment = result["fulfillment"] as! NSDictionary
//            let displayText = fulfillment["displayText"]
            
            // Set current audio
            self.currentMainAudios = [self.getRandomStartingAudioId(), "735"]
            self.currentBackupAudios = []
            if let data = fulfillment["data"] as? NSDictionary {
                
                if let mainAudioIds = data["audio"] as? Array<String> {
                    self.currentMainAudios = [];
                    
                    for mainAudio in mainAudioIds {
                        self.currentMainAudios.append(mainAudio)
                        self.currentMainAudios.append(self.getRandomConnectingAudioId())
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
                
            } else {
                
                // Play I don't know audio
                self.startPlayingAudioSequence()
            }
            
            
        }, failure: { (request, error) in
            print("Error \(error?.localizedDescription)")
        })
        self.apiAi.enqueue(request)
    }
    
    
    // Animations
    func startBlinkAnimations() {
        let waitInterval = 0.5 + Double(arc4random() % 6)
        Timer.scheduledTimer(withTimeInterval: waitInterval, repeats: false, block: { (timer) in
            OperationQueue.main.addOperation {
                self.elonImageView.image = UIImage(named: "blink.png")
            }
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                OperationQueue.main.addOperation {
                    self.elonImageView.image = UIImage(named: "1.png")
                }
            })
            
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
    
    
    // MARK - Callbacks

    @IBAction func requestButtonTapped(_ sender: Any) {
        recognize()
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
        }
    
        let nextIndex = self.gestureRecStartingIndex - Int(translation.x / 2)
        self.currentImageIndex = min(max(0, (nextIndex + self.totalImages) % self.totalImages), 60)
        
        let newImage = UIImage(named: "\(self.currentImageIndex).png")
        self.elonImageView.image = newImage
    }
    
    
    // MARK: - SKTransactionDelegate
    
    func transactionDidBeginRecording(_ transaction: SKTransaction!) {
        // Listening
    }
    
    func transactionDidFinishRecording(_ transaction: SKTransaction!) {
        // Processing request
    }
    
    func transaction(_ transaction: SKTransaction!, didReceive recognition: SKRecognition!) {
        if let recognizedText = recognition.text {
            print("*********** Did Receive recognition \(recognition.text)")
            sendDialogflowRequest(requestString: recognizedText)
        }
    }
    
    func transaction(_ transaction: SKTransaction!, didReceiveServiceResponse response: [AnyHashable : Any]!) {
        print(String(format: "didReceiveServiceResponse: %@", arguments: [response]))
    }
    
    func transaction(_ transaction: SKTransaction!, didFinishWithSuggestion suggestion: String) {
        print("did finish with suggestion \(suggestion)")
        self.skTransaction = nil
    }
    
    func transaction(_ transaction: SKTransaction!, didFailWithError error: Error!, suggestion: String) {
        print(String(format: "didFailWithError: %@. %@", arguments: [error.localizedDescription, suggestion]))
        self.skTransaction = nil
    }
    
    // Helpers
//        OperationQueue.main.addOperation({
//        })
    func getRandomStartingAudioId() -> String {
        let index = Int(arc4random_uniform(UInt32(startingAudioIds.count)))
        return startingAudioIds[index]
    }
    
    func getRandomConnectingAudioId() -> String {
        let index = Int(arc4random_uniform(UInt32(connectingAudioIds.count)))
        return connectingAudioIds[index]
    }
    
    
}

