// SubcharPopup.swift

import UIKit

class SubcharPopup: UIView {
    private var buttons: [UIButton] = []
    var selectionHandler: ((String) -> Void)?
    private var selectedButton: UIButton?
    private var subchars: [String] // Add this line

    init(subchars: [String], isUppercase: Bool) {
        self.subchars = isUppercase ? subchars.map { $0.uppercased() } : subchars
        super.init(frame: .zero) // Add this line
        configureView()
        createButtons(for: self.subchars) // Use self.subchars here
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        backgroundColor = .dynamicPopupColor
        layer.cornerRadius = 6
        layer.masksToBounds = true
    }

    private func createButtons(for subchars: [String]) {
        for subchar in subchars {
            let button = UIButton(type: .custom)
            configureButton(button, withTitle: subchar)
            buttons.append(button)
            addSubview(button)
        }
        updateSelectedButton(to: buttons.first)
    }

    private func configureButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.dynamicTextColor, for: .normal)

        button.layer.cornerRadius = 6
    }


    func selectButton(at point: CGPoint) {
        let index = Int(point.x / (bounds.width / CGFloat(buttons.count)))
        updateSelectedButton(to: buttons[min(max(0, index), buttons.count - 1)])
    }

    private func updateSelectedButton(to button: UIButton?) {
        selectedButton = button
        buttons.forEach { btn in
            btn.backgroundColor = btn == selectedButton ? .systemBlue : .clear
            btn.setTitleColor(btn == selectedButton ? .white : .dynamicTextColor, for: .normal)
        }
    }

    func triggerSelectedButton() {
        if let title = selectedButton?.title(for: .normal) {
            selectionHandler?(title)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtonViews()
    }

    private func layoutButtonViews() {
        let padding: CGFloat = 5
        let buttonWidth = (bounds.width - padding * CGFloat(buttons.count + 1)) / CGFloat(buttons.count)
        for (index, button) in buttons.enumerated() {
            let xPosition = padding + (CGFloat(index) * (buttonWidth + padding))
            button.frame = CGRect(x: xPosition, y: padding, width: buttonWidth, height: bounds.height - 2 * padding)
        }
    }

    func positionAboveKey(_ key: UIView) {
        guard let superview = key.superview else { return }
        frame = CGRect(x: key.frame.origin.x, y: key.frame.origin.y - bounds.height, width: key.frame.width, height: bounds.height)
        superview.addSubview(self)
    }
}
