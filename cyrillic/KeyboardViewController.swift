// KeyboardViewController.swift

import UIKit
import AudioToolbox

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var mainKeyboardView: KeyboardView!
    @IBOutlet var punctuationKeyboardView: KeyboardView!
    @IBOutlet var secondaryPunctuationKeyboardView: KeyboardView!
        
    var isLayoutShifted: Bool = false
    var isLayoutCapsLocked: Bool = false
    var isMainKeyboard: Bool = true
    
    var keyboardHeightConstraint: NSLayoutConstraint?
    var deleteTimer: Timer?
    
    let keyboardHeight: CGFloat = Calculator.getKeyboardHeight()
    let toolbarHeight: CGFloat = Calculator.getToolbar()

    let toolbarView = ToolbarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeKeyboardViews()        
    }
    
    private func initializeKeyboardViews() {
        initilizeToolbarView()
        let needsGlobeKey = self.needsInputModeSwitchKey
        self.mainKeyboardView = KeyboardView(layout: .main, delegate: self, includeGlobeKey: needsGlobeKey)
        self.view.addSubview(self.mainKeyboardView)
        self.setupConstraintsForCurrentKeyboardView()
        
        self.punctuationKeyboardView = KeyboardView(layout: .punctuation, delegate: self, includeGlobeKey: needsGlobeKey)
        self.secondaryPunctuationKeyboardView = KeyboardView(layout: .secondaryPunctuation, delegate: self, includeGlobeKey: needsGlobeKey)
    }

    private func initilizeToolbarView() {
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbarView)
        toolbarView.keyboardViewController = self 

        NSLayoutConstraint.activate([
            toolbarView.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolbarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolbarView.topAnchor.constraint(equalTo: view.topAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: toolbarHeight)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if keyboardHeightConstraint == nil {
            keyboardHeightConstraint = view.heightAnchor.constraint(equalToConstant: keyboardHeight + toolbarHeight)
            keyboardHeightConstraint?.isActive = true
        } else {
            keyboardHeightConstraint?.constant = keyboardHeight + toolbarHeight
        }
        
        handleLayoutSet()
    }
    
    private func setupConstraintsForKeyboardView(_ keyboardView: KeyboardView) {
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            keyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        view.layoutIfNeeded()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateKeyboardLayout(for: size)
        }, completion: { _ in
            self.updateViewSize()
            self.removeAllSubviews()
            self.initializeKeyboardViews()
        })
    }
    
    private func setupConstraintsForCurrentKeyboardView() {
        mainKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainKeyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainKeyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mainKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func removeAllSubviews() {
        view.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func updateKeyboardLayout(for size: CGSize) {
        view.setNeedsDisplay()
        updateSubviews(view: view)
    }
    
    private func updateSubviews(view: UIView) {
        view.setNeedsDisplay()
        view.subviews.forEach {
            if $0 is KeyPopup {
                $0.removeFromSuperview()
            } else {
                updateSubviews(view: $0)
            }
        }
    }
    
    private func updateViewSize() {
        keyboardHeightConstraint?.constant = Calculator.getKeyboardHeight() + Calculator.getToolbar()
        view.layoutIfNeeded()
    }
    
    private func handleLayoutSet() {
        if let context = textDocumentProxy.documentContextBeforeInput, context.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty {
            toggleShift(on: true)
        } else {
            handleAutoCapitalization()
        }
    }
    
    private func switchToPunctuationKeyboard() {
        removeAllSubviews()
        view.addSubview(punctuationKeyboardView)
        setupConstraintsForKeyboardView(punctuationKeyboardView)
        isMainKeyboard = false
    }
    
    private func switchToMainKeyboard() {
        guard let currentKeyboardView = mainKeyboardView else {
            return
        }
        removeAllSubviews()
        view.addSubview(currentKeyboardView)
        setupConstraintsForKeyboardView(currentKeyboardView)
        isMainKeyboard = true
    }
    
    private func switchToSecondaryPunctuationKeyboard() {
        removeAllSubviews()
        view.addSubview(secondaryPunctuationKeyboardView)
        setupConstraintsForKeyboardView(secondaryPunctuationKeyboardView)
        isMainKeyboard = false
    }
    
    private func toggleShift(on: Bool = false) {
        isLayoutShifted = on ? true : false
        mainKeyboardView?.rows.forEach { row in
            row.keys.forEach { key in
                if let characterKey = key as? CharacterKey {
                    let newCharacter = isLayoutShifted ? characterKey.character.uppercased() : characterKey.character.lowercased()
                    characterKey.updateCharacter(newCharacter: newCharacter)
                }
                if key.title(for:.normal) == "shift" {
                    var shiftImageName: String
                    if isLayoutCapsLocked {
                        shiftImageName = "capslock.fill"
                    } else if isLayoutShifted {
                        shiftImageName = "shift.fill"
                    } else {
                        shiftImageName = "shift"
                    }
                    key.setImage(UIImage(named: shiftImageName), for:.normal)
                }
                
                key.setNeedsDisplay()
            }
        }
    }
}

extension KeyboardViewController: KeyDelegate {
    func startContinuousDelete() {
        deleteTimer?.invalidate()
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            if let context = self?.textDocumentProxy.documentContextBeforeInput,!context.isEmpty {
                self?.textDocumentProxy.deleteBackward()
                self?.handleAutoCapitalization()
                AudioServicesPlaySystemSound(1155)
            } else {
                self?.deleteTimer?.invalidate()
                self?.deleteTimer = nil
            }
        }
    }
    
    func stopContinuousDelete() {
        deleteTimer?.invalidate()
        deleteTimer = nil
    }
    
    func isShifted() -> Bool {
        return isLayoutShifted
    }
    
    func keyDidTap(character: String) {
        switch character {
        case "backspace":
            textDocumentProxy.deleteBackward()
            handleAutoCapitalization()
        case "space":
            textDocumentProxy.insertText(" ")
            if !isMainKeyboard {
                switchToMainKeyboard()
            }
            handleAutoCapitalization()
        case "return":
            textDocumentProxy.insertText("\n")
            handleAutoCapitalization()

        case "globe":
            advanceToNextInputMode()
            
        case "shift":
            isLayoutCapsLocked = false
            if isLayoutShifted {
                toggleShift(on: false)
            } else {
                toggleShift(on: true)
            }

        case "123":
            switchToPunctuationKeyboard()
        case "ABC":
            switchToMainKeyboard()
        case "#+=":
            switchToSecondaryPunctuationKeyboard()
        default:
            textDocumentProxy.insertText(character)
            if isLayoutShifted && !isLayoutCapsLocked {
                toggleShift(on: false)
            }
        }
        toolbarView.updatePredictions()
    }
    
    func handleLongPress() {
        
    }
    
    func handleCursorMove(cursorMovement: Int) {
        textDocumentProxy.adjustTextPosition(byCharacterOffset: cursorMovement)
    }
    
    func handleDoubleTap(character: String) {
        switch character {
        case "backspace":
            textDocumentProxy.deleteBackward()
            handleAutoCapitalization()
        case "space":
            handleDoubleTapSpace()
        case "return":
            textDocumentProxy.insertText("\n")
        case "shift":
            isLayoutCapsLocked = true
            toggleShift(on: true)
        default:
            break
        }
    }
    
    private func handleDoubleTapSpace() {
        let context = textDocumentProxy.documentContextBeforeInput
        if context?.suffix(2) != "  " {
            let punctuationMarks: Set<Character> = [".", "!", "?", ",", ":", ";", "-"]
            if let lastCharacter = context?.last, lastCharacter == " " {
                let trimmedText = context?.trimmingCharacters(in:.whitespacesAndNewlines)
                if let lastNonWhitespaceCharacter = trimmedText?.last,!punctuationMarks.contains(lastNonWhitespaceCharacter) {
                    textDocumentProxy.deleteBackward()
                    textDocumentProxy.insertText(".")
                    if !isLayoutShifted {
                        toggleShift(on: true)
                    }
                }
            }
        }
        textDocumentProxy.insertText(" ")
    }
    
    private func handleAutoCapitalization() {
        if let context = textDocumentProxy.documentContextBeforeInput {
            let endOfSentencePunctuation: Set<Character> = [".", "!", "?"]
            let trimmedContext = context.trimmingCharacters(in:.whitespacesAndNewlines)
            if trimmedContext.isEmpty ||
                context.last == "\n" ||
                (context.suffix(2) == ". " || context.suffix(2) == "! " || context.suffix(2) == "? ") {
                toggleShift(on: true)
            } else {
                if isLayoutShifted && !isLayoutCapsLocked {
                    toggleShift(on: false)
                }
            }
        } else {
            if !isLayoutShifted && !isLayoutCapsLocked {
                toggleShift(on: true)
            }
        }
    }
}
