// SpecialKey.swift

import UIKit
import AudioToolbox

class SpecialKey: KeyBase {
    private var keyLabel: String
    private var longPressTimer: Timer?
    private var lastTapTime: Date?
    private var initialTouchLocation: CGPoint?
    private var isCursorMovement: Bool = false
    private var isCursorMoved: Bool = false
    
    weak override var delegate: KeyDelegate? {
        didSet {
            if keyLabel == "globe" {
                delegate?.setGlobeKeySelector(globeKey: self)
            }
        }
    }
    
    init(keyLabel: String) {
        self.keyLabel = keyLabel
        super.init(frame: .zero)
        configureKey()
        clickFeedback.prepare()
        longPressFeedback.prepare()
    }

    required init?(coder aDecoder: NSCoder) {
        self.keyLabel = ""
        super.init(coder: aDecoder)
        configureKey()
    }

    private func configureKey() {
        switch keyLabel {
        case "backspace":
            self.keyColor = UIColor.dynamicActionKeyColor
            self.fontSize = 0
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.tintColor = UIColor.dynamicTextColor
            self.setImage(UIImage(named: "delete.left"), for: .normal)
        case "space":
            self.fontSize = 14
        case "⌫":
            self.keyColor = UIColor.dynamicActionKeyColor
            self.fontSize = 22
        case "shift":
            self.keyColor = UIColor.dynamicActionKeyColor
            self.fontSize = 0
            self.imageView?.tintColor = UIColor.dynamicTextColor
            self.setImage(UIImage(named: "shift"), for: .normal)
        case "globe":
            self.keyColor = UIColor.dynamicActionKeyColor
            self.fontSize = 0
            self.imageView?.tintColor = UIColor.dynamicTextColor
            if let globeImage = UIImage(named: "globe"),
               let resizedGlobeImage = resizeImage(globeImage, toWidth: 20, toHeight: 20) {
                self.setImage(resizedGlobeImage.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            self.setTitle("", for: .normal)
            self.imageView?.tintColor = UIColor.dynamicTextColor
            self.imageView?.contentMode = .scaleAspectFit
            
        case "return":
            self.keyColor = UIColor.dynamicActionKeyColor
            self.fontSize = 0
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.tintColor = UIColor.dynamicTextColor
            self.setImage(UIImage(named: "return"), for: .normal)
        default:
            self.keyColor = UIColor.dynamicActionKeyColor
            self.fontSize = 15
        }
               
        setTitle(keyLabel, for: .normal)
        
        setTitleColor(UIColor.clear, for: .normal)
        addTarget(self, action: #selector(keyTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if let imageView = self.imageView, let image = imageView.image {
            let imageFrame = CGRect(x: (bounds.width - image.size.width) / 2.0,
                                    y: (bounds.height - image.size.height) / 2.0 + basePadding - 1,
                                    width: image.size.width,
                                    height: image.size.height)
            imageView.frame = imageFrame
        }

        if let titleLabel = self.titleLabel, let text = titleLabel.text {
            let textSize = text.size(withAttributes: [NSAttributedString.Key.font: titleLabel.font ?? UIFont.systemFont(ofSize: 0)])
            let textFrame = CGRect(x: (bounds.width - textSize.width) / 2.0,
                                   y: bounds.height - textSize.height - 5, // Position title at the bottom or adjust as needed
                                   width: textSize.width,
                                   height: textSize.height)
            titleLabel.frame = textFrame
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Prepare for potential long press without initiating cursor movement yet
        if keyLabel == "space" {
            if let touch = touches.first {
                initialTouchLocation = touch.location(in: self)
            }
        }
        self.keyColor = keyLabel == "space" ? UIColor.dynamicActionKeyColor : UIColor.dynamicKeyColor
        if self.keyLabel == "backspace" { setImage(UIImage(named: "delete.left.fill"), for: .normal) }
        self.setNeedsDisplay()

        clickFeedback.impactOccurred()
        AudioServicesPlaySystemSound(keyLabel == "backspace" ? 1155 : 1156)

        longPressTimer?.invalidate()
        longPressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleLongPress), userInfo: nil, repeats: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let initialLocation = initialTouchLocation, isCursorMovement else { return }
        
        let currentLocation = touch.location(in: self)
        let movementThreshold: CGFloat = 10.0
        let movement = currentLocation.x - initialLocation.x

        if abs(movement) > movementThreshold {
            // Move cursor based on the direction of the movement
            let cursorMovement = Int(movement / movementThreshold)
            if cursorMovement != 0 {
                delegate?.handleCursorMove(cursorMovement: cursorMovement)
                initialTouchLocation = currentLocation
            }
            isCursorMoved = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        initialTouchLocation = nil
        isCursorMovement = false
        
        self.keyColor = keyLabel == "space" ? UIColor.dynamicKeyColor : UIColor.dynamicActionKeyColor
        if self.keyLabel == "backspace" { setImage(UIImage(named: "delete.left"), for: .normal) }
        self.setNeedsDisplay()
        
        longPressTimer?.invalidate()
        longPressTimer?.prepareForInterfaceBuilder()
        delegate?.stopContinuousDelete()
    }
    
    func resizeImage(_ image: UIImage, toWidth width: CGFloat, toHeight height: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }

    
    @objc private func keyTapped() {
        let currentTime = Date()
        if let lastTapTime = lastTapTime, currentTime.timeIntervalSince(lastTapTime) <= 0.5 {
            delegate?.handleDoubleTap(character: keyLabel)
        } else {
            isCursorMoved ? isCursorMoved = false : delegate?.keyDidTap(character: keyLabel)
        }
        lastTapTime = currentTime
    }
    
    @objc private func handleLongPress() {
        longPressFeedback.impactOccurred()
        if keyLabel == "space" {
            isCursorMovement = true
        }
        if keyLabel == "backspace" {
            delegate?.startContinuousDelete()
        }
    }
    
}

