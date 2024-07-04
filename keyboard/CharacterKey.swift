// CharacterKey.swift

import UIKit
import AudioToolbox

class CharacterKey: KeyBase {
    var character: String
    var hint: String = ""
    var subchars: [String] = []
    var subcharSelected: Bool = false

    weak var popupView: KeyPopup?
    weak var subcharPopupView: SubcharPopup?
    private var longPressTimer: Timer?

    init(character: String, hint: String = "", subkeys: [String] = []) {
        self.character = character
        super.init(frame: .zero)
        configureKey()
        self.hint = hint
        self.subchars = subkeys
        clickFeedback.prepare()
        longPressFeedback.prepare()
    }

    required init?(coder aDecoder: NSCoder) {
        self.character = ""
        super.init(coder: aDecoder)
        configureKey()
    }

    private func configureKey() {
        titleLabel?.font = UIFont.systemFont(ofSize: 22)
        setTitle(character, for: .normal)
        setTitleColor(UIColor.clear, for: .normal)
        addTarget(self, action: #selector(keyTapped), for: .touchUpInside)
        self.keyColor = .dynamicKeyColor
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawHint(in: rect)
    }
        
    private func drawHint(in rect: CGRect) {
        // Ensure the graphics context is available
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var color: UIColor
        if #available(iOSApplicationExtension 13.0, *) {
            color = UIColor.dynamicHintColor
        } else {
            color = UIColor.black
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: color
        ]
        
        let attributedString = NSAttributedString(string: hint, attributes: attributes)
        let stringSize = attributedString.size()
        let stringRect = CGRect(
            x: rect.maxX - stringSize.width - 5,
            y: rect.minY + basePadding * 2 + 1,
            width: stringSize.width,
            height: stringSize.height
        )
        
        context.saveGState() // Save the current state
        attributedString.draw(in: stringRect)
        context.restoreGState() // Restore the state
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showPopup()
        AudioServicesPlaySystemSound(1123)
        clickFeedback.impactOccurred()
        
        longPressTimer?.invalidate()
        longPressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleLongPress), userInfo: nil, repeats: false)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first, let subcharPopupView = subcharPopupView {
            let locationInView = touch.location(in: subcharPopupView)
            subcharPopupView.selectButton(at: locationInView)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hidePopup()
        subcharPopupView?.triggerSelectedButton()
        hideSubcharPopup()
        clickFeedback.prepare()
        
        longPressTimer?.invalidate()
        longPressTimer?.prepareForInterfaceBuilder()
        delegate?.stopContinuousDelete()
    }
    
    private func showPopup() {
        if popupView == nil {
            let popup = KeyPopup(key: self)
            addSubview(popup)
            popupView = popup
        }
        popupView?.isHidden = false
    }

    private func hidePopup() {
        popupView?.isHidden = true
    }

    func updateCharacter(newCharacter: String) {
        character = newCharacter
        setTitle(character, for: .normal)
        setNeedsDisplay()
        
        self.popupView?.removeFromSuperview()
    }

    @objc private func keyTapped() {
        if !subcharSelected {
            delegate?.keyDidTap(character: character)
        }
    }
    
    @objc private func handleLongPress() {
        if subchars.isEmpty { return }
        subcharSelected = true
        showSubcharPopup()
        longPressFeedback.impactOccurred()
    }

    private func showSubcharPopup() {
        if !subchars.contains(character.lowercased()) {
            if hint.isEmpty {
                subchars.insert(character.lowercased(), at: 0)
            } else {
                subchars.insert(character.lowercased(), at: 1)
            }
        }
        let shifted = delegate?.isShifted()
        let popup = SubcharPopup(subchars: subchars, isUppercase: shifted!)
        popup.selectionHandler = { [weak self] selectedSubchar in
            self?.hideSubcharPopup()
            self?.subcharSelected = true
            self?.delegate?.keyDidTap(character: selectedSubchar)
        }
        addSubview(popup)

        let screenWidth = UIScreen.main.bounds.width
        let popupWidth = self.bounds.width * CGFloat(subchars.count)
        var popupX = -basePadding - basePadding

        // Adjust the x-coordinate and width if the popup goes beyond the screen
        if self.frame.minX + popupWidth > screenWidth {
            let overflow = self.frame.minX + popupWidth - screenWidth
            popupX -= overflow
        }

        popup.frame = CGRect(x: popupX, y: -self.bounds.height + basePadding * 3, width: popupWidth, height: self.bounds.height - basePadding * 2)
        subcharPopupView = popup
    }

    private func hideSubcharPopup() {
        subcharSelected = false
        subcharPopupView?.removeFromSuperview()
    }
}

