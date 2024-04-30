// CustomKeyButton.swift

import UIKit

class CustomKeyButton: UIButton {
    
    var isSpecialKey: Bool = false
    var hintCharacter: String?
    var popOutLabel: UILabel?

    let specialKeyColor = UIColor(
                red: 178.0 / 255.0,
                green: 182.0 / 255.0,
                blue: 193.0 / 255.0,
                alpha: 1.0
            )
    
    private let padding: CGFloat = 3.3 // Adjust padding size as needed
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        
        // Adjust rect for padding
        let paddedRect = rect.insetBy(dx: padding, dy: padding * 2)
        
        // Set shadow properties
        context.setShadow(offset: CGSize(width: 0, height: 1), blur: 0.1, color: UIColor.gray.cgColor)
        
        // Drawing a rounded rectangle inside the padded rect
        let roundedRectPath = UIBezierPath(roundedRect: paddedRect, cornerRadius: 5)
        context.addPath(roundedRectPath.cgPath)
        
        let fillColor: UIColor = isSpecialKey ? specialKeyColor : .white  // Gray for special keys, white for others
        context.setFillColor(fillColor.cgColor) // Fill color for the key
        context.fillPath()
        
        context.restoreGState()
        
        // Draw the title (key label) in the center
        drawTitle(in: paddedRect)
    }
    
    private func drawTitle(in rect: CGRect) {
        // Ensure the title is set
        guard let title = title(for: .normal), let font = titleLabel?.font else { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.clear
        ]
        
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        let stringSize = attributedString.size()
        let stringRect = CGRect(
            x: rect.midX - stringSize.width / 2,
            y: rect.midY - stringSize.height / 2,
            width: stringSize.width,
            height: stringSize.height
        )
        
        if let hint = hintCharacter, !hint.isEmpty {
            let hintAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),  // Smaller font size for the hint
                .foregroundColor: UIColor.gray
            ]
            
            let hintAttributedString = NSAttributedString(string: hint, attributes: hintAttributes)
            let hintSize = hintAttributedString.size()
            let hintRect = CGRect(
                x: rect.maxX - hintSize.width - 2,  // Positioning hint towards the top-right corner
                y: rect.minY + 2,
                width: hintSize.width,
                height: hintSize.height
            )
            
            hintAttributedString.draw(in: hintRect)
        }
        
        attributedString.draw(in: stringRect)
    }
    
    // Override the touchesBegan function to handle the initial touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showPopOut()
    }

    // Override the touchesEnded function to handle the touch release event
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hidePopOut()
    }

    // Function to show the pop-out effect
    private func showPopOut() {
        guard let keyTitle = self.title(for: .normal) else { return }
        
        // Create and setup the pop-out label if it doesn't exist
        if popOutLabel == nil {
            popOutLabel = UILabel()
            popOutLabel?.textAlignment = .center
            popOutLabel?.backgroundColor = .white
            popOutLabel?.textColor = .black
            popOutLabel?.layer.cornerRadius = 5
            popOutLabel?.layer.masksToBounds = true
            // Add more styling as needed
        }
        
        popOutLabel?.text = keyTitle
        popOutLabel?.font = self.titleLabel?.font.withSize(25) // Adjust size as needed
        
        let scaleFactor: CGFloat = 1.2
        let scaledWidth = self.frame.width * scaleFactor
        let scaledHeight = self.frame.height * scaleFactor
        let xOffset = (scaledWidth - self.frame.width) / 2
        let yOffset = (scaledHeight - self.frame.height) / 2

        popOutLabel?.frame = CGRect(
            x: -xOffset,
            y: -self.frame.height - yOffset,
            width: scaledWidth,
            height: scaledHeight
        )
        if let popOutLabel = popOutLabel {
            self.addSubview(popOutLabel)
        }
    }

    // Function to hide the pop-out effect
    private func hidePopOut() {
        self.popOutLabel?.removeFromSuperview()
    }

}
