//
//  ChatBubbleView.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit

class ChatBubbleView: UIView {
    
    private var bubbleTimer: Timer?

    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var bubbleLabel: UILabel!
    
    
    
    class func instanceFromNib() -> ChatBubbleView {
        return UINib(nibName: "ChatBubbleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChatBubbleView
    }
    
    func showAnimatedBubble(text: String, duration: TimeInterval) {
        self.bubbleTimer?.invalidate()
        
        bubbleLabel.alpha = 0
        bubbleImageView.alpha = 0
        bubbleLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        bubbleImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        OperationQueue.main.addOperation {
            self.bubbleLabel.text = text
            UIView.animate(withDuration: 0.5, animations: {
                self.bubbleLabel.alpha = 1.0
                self.bubbleImageView.alpha = 1.0
                self.bubbleLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.bubbleImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        self.bubbleTimer = Timer.scheduledTimer(withTimeInterval: duration-0.5, repeats: false) { (timer) in
            OperationQueue.main.addOperation {
                UIView.animate(withDuration: 0.5, animations: {
                    self.bubbleLabel.alpha = 0
                    self.bubbleImageView.alpha = 0
                    self.bubbleLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    self.bubbleImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                })
            }
        }
    }
    
    func hideAnimatedBubble() {
        self.bubbleTimer?.invalidate()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.bubbleLabel.alpha = 0
            self.bubbleImageView.alpha = 0
            self.bubbleLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.bubbleImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        })
    }

}
