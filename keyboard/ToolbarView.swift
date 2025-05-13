import UIKit

class ToolbarView: UIView {
    
    private let hideKeyboardButton = UIButton(type: .system)
    private var suggestionButtons: [UIButton] = []
    private var separatorViews: [UIView] = []
    weak var keyboardViewController: KeyboardViewController? 

    private let suggestionsStackView = UIStackView()
    private var suggestions: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureToolbar()
        setupSuggestionButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureToolbar() {
        setupHideKeyboardButton()
        configureLayout()
    }

    private func setupHideKeyboardButton() {
        hideKeyboardButton.setImage(UIImage(named: "keyboard.down"), for: .normal)
        hideKeyboardButton.tintColor = .dynamicTextColor
        hideKeyboardButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        hideKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hideKeyboardButton)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            hideKeyboardButton.topAnchor.constraint(equalTo: topAnchor),
            hideKeyboardButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            hideKeyboardButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            hideKeyboardButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupSuggestionButtons() {
        for _ in 0..<3 {
            let button = UIButton()
            button.setTitleColor(.dynamicTextColor, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(button)
            suggestionButtons.append(button)
        }
        
        for _ in 0..<2 {
            let separator = UIView()
            separator.backgroundColor = .separator
            separator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(separator)
            separatorViews.append(separator)
        }
        
        let padding: CGFloat = 0
        
        for (index, button) in suggestionButtons.enumerated() {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor, constant: padding),
                button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
                button.heightAnchor.constraint(equalTo: heightAnchor, constant: -padding * 2)
            ])
            
            if index == 0 {
                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: separatorViews[index - 1].trailingAnchor, constant: padding).isActive = true
                button.widthAnchor.constraint(equalTo: suggestionButtons[0].widthAnchor).isActive = true
            }
            
            if index < separatorViews.count {
                let separator = separatorViews[index]
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: padding),
                    separator.centerYAnchor.constraint(equalTo: centerYAnchor),
                    separator.widthAnchor.constraint(equalToConstant: 1),
                    separator.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6)
                ])
            }
        }
        
        if let lastButton = suggestionButtons.last {
            lastButton.trailingAnchor.constraint(equalTo: hideKeyboardButton.leadingAnchor, constant: -padding).isActive = true
        }
    }

    @objc private func hideKeyboard() {
        keyboardViewController?.dismissKeyboard()
    }

    func setHideKeyboardButtonHidden(_ hidden: Bool) {
        hideKeyboardButton.isHidden = hidden
    }

    func updateSuggestions(_ suggestions: [String]) {
        for (index, button) in suggestionButtons.enumerated() {
            UIView.animate(withDuration: 0.10, animations: {
                button.alpha = 0.5
            }, completion: { _ in
                if index < suggestions.count {
                    button.setTitle(suggestions[index], for: .normal)
                    button.isHidden = false
                    UIView.animate(withDuration: 0.10) {
                        button.alpha = 1
                    }
                } else {
                    button.isHidden = true
                }
            })
        }
    }

    @objc private func suggestionTapped(_ sender: UIButton) {
        guard let word = sender.title(for: .normal) else { return }
        keyboardViewController?.replaceCurrentWord(with: word)
    }
}
