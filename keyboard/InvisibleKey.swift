// CharacterKey.swift

import UIKit
import AudioToolbox

class InvisibleKey: KeyBase {
    init() {
        super.init(frame: .zero)
        configureKey()
        clickFeedback.prepare()
        longPressFeedback.prepare()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureKey()
    }

    private func configureKey() {
        self.keyColor = .cyan
    }
    
    override func draw(_ rect: CGRect) {}
    
}

