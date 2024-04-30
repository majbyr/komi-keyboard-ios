import UIKit

class KeyRow: UIView {
    weak var delegate: KeyDelegate?
    var keys: [KeyBase] = []
    private let specialKeysLabels: Set<String> = ["123", "globe", "space", "return", "ABC", "#+=", "backspace", "shift"]
    private let biggestRowLength: Int

    init(keys: [String], delegate: KeyDelegate?, biggestRowLength: Int = 12, hints: [String:String] = [:], subkeys: [String:[String]] = [:]) {
        self.delegate = delegate
        self.biggestRowLength = biggestRowLength
        super.init(frame: .zero)
        
        self.keys = keys.map { keyLabel in
            specialKeysLabels.contains(keyLabel) ? SpecialKey(keyLabel: keyLabel) : CharacterKey(character: keyLabel, hint: hints[keyLabel] ?? "", subkeys: subkeys[keyLabel] ?? [])
        }
        setupRow()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupRow() {
        let standardMultiplier = 1.0 / CGFloat(biggestRowLength)
        
        keys.forEach { key in
            addSubview(key)
            key.delegate = delegate
            key.translatesAutoresizingMaskIntoConstraints = false
            setupKeyConstraints(key: key, standardMultiplier: standardMultiplier)
        }
    }

    private func setupKeyConstraints(key: KeyBase, standardMultiplier: CGFloat) {
        key.topAnchor.constraint(equalTo: topAnchor).isActive = true
        key.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if let index = keys.firstIndex(of: key) {
            key.leadingAnchor.constraint(equalTo: index == 0 ? self.leadingAnchor : keys[index - 1].trailingAnchor).isActive = true

            if index == keys.count - 1 {
                key.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            } else {
                let multiplier = calculateMultiplierForKey(key: key, standardMultiplier: standardMultiplier)
                key.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier).isActive = true
            }
        }
    }

    private func calculateMultiplierForKey(key: KeyBase, standardMultiplier: CGFloat) -> CGFloat {
        let isSpaceRow = keys.contains { ($0 as? SpecialKey)?.titleLabel?.text == "space" }
        let isSwitcherInRow = keys.contains { ($0 as? SpecialKey)?.titleLabel?.text == "123" } || keys.contains { ($0 as? SpecialKey)?.titleLabel?.text == "ABC" }
        let spaceKey = key.titleLabel?.text == "space"
        let returnKey = key.titleLabel?.text == "return"
        let specialKey = key is SpecialKey && !spaceKey && !returnKey

        let specialKeysCount = keys.filter { $0 is SpecialKey 
            && !$0.titleLabel!.text!.contains("space")
            && !$0.titleLabel!.text!.contains("return")}.count
        let characterKeysCount = keys.filter { $0 is CharacterKey }.count

        if spaceKey, isSpaceRow {
            var multiplier = 1.0 // full row
            multiplier -= standardMultiplier * CGFloat(characterKeysCount) // minus character keys multiplier
            multiplier -= standardMultiplier * 1.25 * CGFloat(specialKeysCount) // minus special keys multiplier
            multiplier -= standardMultiplier * 2 // minus return key multiplier
            if isSwitcherInRow, specialKeysCount == 1{
                multiplier -= standardMultiplier * 0.75
            }
            return multiplier // now it take all free space
        } else if returnKey {
            return 2 * standardMultiplier
        } else if isSpaceRow && specialKeysCount == 1 && (key.titleLabel?.text == "123" || key.titleLabel?.text == "ABC") {
            return 2 * standardMultiplier
        } else if !isSpaceRow && keys.count <= 7 {
            return 1.0 / CGFloat(keys.count)
        } else if specialKey {
            return keys.count == biggestRowLength ? standardMultiplier : 1.25 * standardMultiplier
        } else {
            return standardMultiplier
        }
    }
}
