import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupConstraints()
    }
    
    private func configureUI() {
        _ = HeaderViewConfigurator(view: view)
        setupSettingsMenu()
        setupTextField()
        setupLinksMenu()
    }
    
    private func setupTextField() {
        let textField = TextField()
        NSLayoutConstraint.activate([textField.heightAnchor.constraint(equalToConstant: 45)])
        view.addSubview(textField)
        textField.delegate = self
    }
    
    private func setupSettingsMenu() {
        let settingsStackView = MenuStackView(
            title: NSLocalizedString("SETTING", comment: ""),
            hint: NSLocalizedString("SetupInstruction", comment: ""),
            buttonDetails: [
                (title: NSLocalizedString("OpenAppSettings", comment: ""), imageName: "settings", target: self, action: #selector(openSettings))])
        
        view.addSubview(settingsStackView)
    
    }
    
    private func setupLinksMenu() {
        let linksStackView = MenuStackView(
            title: NSLocalizedString("LINKS", comment: ""),
            hint: "",
            buttonDetails: [
                (title: NSLocalizedString("AppStore", comment: ""), imageName: "app.store", target: self, action: #selector(openAppStore)),
                (title: NSLocalizedString("GitHub", comment: ""), imageName: "github", target: self, action: #selector(openGitHub)),
                (title: NSLocalizedString("Website", comment: ""), imageName: "safari", target: self, action: #selector(openWebsite))
            ]
        )

        view.addSubview(linksStackView)
    
    }
    
    private func setupConstraints() {
        var previousSubview: UIView?

        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false

            // First subview constraints to the top of the safe area layout guide
            if let previous = previousSubview {
                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 30),
                    subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
            } else {
                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
            }
            
            previousSubview = subview // Update the previous subview reference to the current one
        }
    }

    
    // MARK: - Actions for Settings and Links
    @objc private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    @objc private func openAppStore() {
        // Implementation to open the App Store link
        let appStoreUrl = URL(string: "https://apps.apple.com/us/developer/aleksei-ivanov/id1536776623")
        UIApplication.shared.open(appStoreUrl!)
    }
    
    @objc private func openGitHub() {
        // Implementation to open GitHub link
        let gitHubUrl = URL(string: "https://github.com/AlexDjSun/komi-keyboard-ios")
        UIApplication.shared.open(gitHubUrl!)
    }
    
    @objc private func openWebsite() {
        // Implementation to open Website link
        let websiteUrl = URL(string: "https://majbyr.com/")
        UIApplication.shared.open(websiteUrl!)
    }
}
