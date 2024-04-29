// KeyPopup.swift

import UIKit

class KeyPopup: UIView {
    private var keyLabel: UILabel
    private var key: KeyBase
    
    init(key: KeyBase) {
        self.key = key
        self.keyLabel = UILabel(frame: CGRect.zero)
        
        let popupWidth = key.bounds.width * 2
        let popupHeight = key.bounds.height * 1.75
        let popupX = (popupWidth - key.bounds.width) / 2
        let popupY = (key.basePadding + 1) + (key.bounds.height * 0.75)
        super.init(frame: CGRect(x: -popupX, y: -popupY , width: popupWidth, height: popupHeight))
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        keyLabel.text = key.title(for: .normal)
        keyLabel.textAlignment = .center
        keyLabel.font = UIFont.systemFont(ofSize: 24)
        addSubview(keyLabel)
        backgroundColor = .clear
        layer.masksToBounds = true
    }

    
    override func draw(_ rect: CGRect) {
        let keyWidth = key.bounds.width - key.basePadding * 2
        let keyHeight = key.bounds.height
        let popupWidth = self.bounds.width
        // let popupHeight = self.bounds.height
        
        let bottomShapeRect = CGRect(
            x: (popupWidth - keyWidth) / 2,
            y: 0,
            width: keyWidth,
            height: keyHeight * 1.75
        )
        drawKeyShape(in: bottomShapeRect, color: .dynamicPopupColor)
        
        let transitionShapeRect = CGRect(
            x: (popupWidth - keyWidth * 1.75) / 2,
            y: keyHeight * 0.75,
            width: keyWidth * 1.75,
            height: keyHeight / 2
        )
        
        let path = keyPreviewPath(in: transitionShapeRect, keyWidth: keyWidth)
        UIColor.dynamicPopupColor.setFill()
        path.fill()
        
        // Center the second shape (white color)
        let topShapeRect = CGRect(
            x: (popupWidth - keyWidth * 1.5) / 2,
            y: 0,
            width: keyWidth * 1.5,
            height: keyHeight * 0.75
        )
        drawKeyShape(in: topShapeRect, color: .dynamicPopupColor)
        drawKeyTitle(in: topShapeRect)
        
        // add a shadow
        layer.shadowColor = UIColor.dynamicShadowColor.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 2
    }
    
    private func drawKeyShape(in rect: CGRect, color: UIColor) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5)
        color.setFill()
        path.fill()
    }
    
    private func drawKeyTitle(in rect: CGRect) {
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32),
            NSAttributedString.Key.foregroundColor: UIColor.dynamicTextColor
        ]
        let attributedString = NSAttributedString(string: keyLabel.text!, attributes: attributes)
        let stringSize = attributedString.size()
        let stringRect = CGRect(
            x: rect.midX - stringSize.width / 2,
            y: rect.midY - stringSize.height / 2,
            width: stringSize.width,
            height: stringSize.height
        )
        attributedString.draw(in: stringRect)
    }
    
    private func keyPreviewPath(in rect: CGRect, keyWidth: CGFloat) -> UIBezierPath {
        // Replace these values with the actual dimensions and properties of your key
        //let keyWidth = rect.width / 2
        let keyHeight = rect.height / 1.75
        let keyCornerRadius: CGFloat = 0
        let previewCornerRadius: CGFloat = 0
        
        let origin = CGPoint(x: rect.midX, y: rect.maxY)
        let expansionWidth: CGFloat = keyWidth / 4
        let curveDistance: CGFloat = expansionWidth * 1.5
        let controlDistance: CGFloat = curveDistance / 3.0
        
        let pointA: CGPoint = CGPoint(x: origin.x - (keyWidth / 2.0), y: origin.y)
        let pointBArcCenter: CGPoint = CGPoint(x: pointA.x, y: pointA.y)
        let pointC: CGPoint = CGPoint(x: origin.x - (keyWidth / 2.0), y: origin.y - keyHeight)
        
        let pointD: CGPoint = CGPoint(x: pointC.x - expansionWidth, y: pointC.y - curveDistance)
        let curve1Control1: CGPoint = CGPoint(x: pointC.x, y: pointC.y - controlDistance)
        let curve1Control2: CGPoint = CGPoint(x: pointD.x, y: curve1Control1.y)
        
        let pointE: CGPoint = CGPoint(x: pointD.x, y: pointD.y - keyHeight)
        let pointFArcCenter: CGPoint = CGPoint(x: pointE.x, y: pointE.y)
        
        let maxWidth: CGFloat = keyWidth + (expansionWidth * 2)
        let pointG: CGPoint = CGPoint(x: pointFArcCenter.x + (maxWidth - previewCornerRadius * 2), y: pointFArcCenter.y - previewCornerRadius)
        let pointHArcCenter: CGPoint = CGPoint(x: pointG.x, y: pointFArcCenter.y)
        
        let pointJ: CGPoint = CGPoint(x: pointHArcCenter.x + previewCornerRadius, y: pointD.y)
        let pointK: CGPoint = CGPoint(x: pointC.x + keyWidth, y: pointC.y)
        let curve2Control1: CGPoint = CGPoint(x: pointJ.x, y: curve1Control1.y)
        let curve2Control2: CGPoint = CGPoint(x: pointK.x, y: curve2Control1.y)
        
        let pointL: CGPoint = CGPoint(x: origin.x + (keyWidth / 2.0), y: pointBArcCenter.y)
        let pointMArcCenter: CGPoint = CGPoint(x: pointL.x, y: pointL.y)
        
        let path = UIBezierPath()
        path.move(to: origin)
        
        path.addLine(to: pointA)
        path.addArc(withCenter: pointBArcCenter, radius: keyCornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi, clockwise: false)
        
        path.addLine(to: pointC)
        path.addCurve(to: pointD, controlPoint1: curve1Control1, controlPoint2: curve1Control2)
        
        path.addLine(to: pointE)
        path.addArc(withCenter: pointFArcCenter, radius: previewCornerRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: false)
        
        path.addLine(to: pointG)
        path.addArc(withCenter: pointHArcCenter, radius: previewCornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: 0, clockwise: false)
        
        path.addLine(to: pointJ)
        path.addCurve(to: pointK, controlPoint1: curve2Control1, controlPoint2: curve2Control2)
        
        path.addLine(to: pointL)
        path.addArc(withCenter: pointMArcCenter, radius: keyCornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: false)
        
        path.addLine(to: origin)
        
        return path
    }
    
}
