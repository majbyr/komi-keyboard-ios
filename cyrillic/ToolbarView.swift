import UIKit

class ToolbarView: UIView {
    
    private let hideKeyboardButton = UIButton(type: .system)
    weak var keyboardViewController: KeyboardViewController? // Keep reference weak to avoid retain cycles

    private let suggestionsStackView = UIStackView()
    private var suggestions: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureToolbar()
        // configureSuggestionsView()
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

    @objc private func hideKeyboard() {
        keyboardViewController?.dismissKeyboard()
    }

    func setHideKeyboardButtonHidden(_ hidden: Bool) {
        hideKeyboardButton.isHidden = hidden
    }

    private func configureSuggestionsView() {
        suggestionsStackView.axis = .horizontal
        suggestionsStackView.distribution = .fillEqually
        suggestionsStackView.spacing = 10
        suggestionsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(suggestionsStackView)

        NSLayoutConstraint.activate([
            suggestionsStackView.leftAnchor.constraint(equalTo: leftAnchor),
            suggestionsStackView.rightAnchor.constraint(equalTo: hideKeyboardButton.leftAnchor, constant: -10),
            suggestionsStackView.topAnchor.constraint(equalTo: topAnchor),
            suggestionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func updateSuggestions(words: [String]) {
        suggestionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for word in words {
            let button = UIButton(type: .system)
            button.setTitle(word, for: .normal)
            button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionsStackView.addArrangedSubview(button)
        }
    }

    @objc private func suggestionTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        // Delegate or callback to insert the word
        keyboardViewController?.textDocumentProxy.insertText(title + " ")
    }
    
    func updatePredictions() {
        guard let currentText = keyboardViewController?.textDocumentProxy.documentContextBeforeInput else { return }
        let lastWord = currentText.components(separatedBy: CharacterSet.whitespacesAndNewlines).last ?? ""
        let suggestions = getPredictions(for: lastWord)
        self.updateSuggestions(words: suggestions)
    }

    private func getPredictions(for input: String) -> [String] {
        // Placeholder function to simulate predictions
        let allWords = ["чолӧм", "ме", "кӧсъя", "лун", "быд", "гиж", "аски"]
        return allWords.filter { $0.hasPrefix(input.lowercased()) }
    }
}
