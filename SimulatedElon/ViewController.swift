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

class ViewController: UIViewController, AVAudioPlayerDelegate, SKTransactionDelegate, UIGestureRecognizerDelegate {
    
    // Logic
    private var currentAudioId: String?
    private var audioPlayerInitialized = false
    private var currentMainAudios: [String] = []
    private var currentBackupAudios: [String] = []
    private var currentAudioIndex: Int = 0
    
    private let totalImages: Int = 60
    private var currentImageIndex: Int = 1
    private var gestureRecStartingIndex: Int = 1
    
    let startingAudioIds = ["569", "570", "593"]
    let connectingAudioIds = ["544", "545", "546", "547", "548", "553", "561", "566", "582", "584", "595", "596", "5110", "23", "77", "78", "717"]
    
    
    var audioPlayer = AVAudioPlayer()
    var apiAi: ApiAI
    var skSession:SKSession?
    var skTransaction:SKTransaction?
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var elonImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    
    
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
        
        playAudioFileWithId(audioFileId: "513")
    }
    
    func recognize() {
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
        skTransaction!.stopRecording()
    }
    
    func cancelRecording() {
        skTransaction!.cancel()
    }
    
    private func playAudioFileWithId(audioFileId: String) {
        print("***** Play Audio File: \(audioFileId)")
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
        } else {
            print("Audio file not found")
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
            print("response \(responseRaw)")
            let response = responseRaw as! NSDictionary
            let result = response["result"] as! NSDictionary
            let fulfillment = result["fulfillment"] as! NSDictionary
            let displayText = fulfillment["displayText"]
            
            // Set current audio
            self.currentMainAudios = [self.getRandomStartingAudioId(), "735"]
            self.currentBackupAudios = []
            if let data = fulfillment["data"] as? NSDictionary {
                
                if let mainAudioIds = data["audio"] as? Array<String> {
                    self.currentMainAudios = [self.getRandomStartingAudioId()];
                    
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
            print("Error \(error)")
        })
        self.apiAi.enqueue(request)
    }
    

    @IBAction func requestButtonTapped(_ sender: Any) {
        recognize()
    }
    
    // MARK - AudioDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.currentAudioIndex += 1
        if self.currentAudioIndex < self.currentMainAudios.count {
            // play main audio
            playAudioFileWithId(audioFileId: currentMainAudios[currentAudioIndex])
        } else {
            // start playing backup audio intermittently
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

