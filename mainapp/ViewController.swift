import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    var scrollView: UIScrollView!
    var contentView: UIView!

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Setup constraints for scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Setup constraints for contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        configureUI()
        setupConstraints()
    }
    
    private func configureUI() {
        _ = HeaderViewConfigurator(view: view)
        view.backgroundColor = .dynamicBackgroundColor
        setupSettingsMenu()
        setupTextField()
        setupLinksMenu()
    }
    
    
    private func setupTextField() {
        let textField = TextField()
        NSLayoutConstraint.activate([textField.heightAnchor.constraint(equalToConstant: 45)])
        contentView.addSubview(textField)
        textField.delegate = self
    }
    
    private func setupSettingsMenu() {
        let settingsStackView = MenuStackView(
            title: NSLocalizedString("SETTING", comment: ""),
            hint: NSLocalizedString("SetupInstruction", comment: ""),
            buttonDetails: [
                (title: NSLocalizedString("OpenAppSettings", comment: ""), imageName: "settings", target: self, action: #selector(openSettings))])
        
        contentView.addSubview(settingsStackView)
    
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

        contentView.addSubview(linksStackView)
    
    }
    
    private func setupConstraints() {
        var previousSubview: UIView?

        for subview in contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false

            // First subview constraints to the top of the safe area layout guide
            if let previous = previousSubview {
                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 30),
                    subview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    subview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
            } else {
                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
                    subview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    subview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
            }
            
            previousSubview = subview // Update the previous subview reference to the current one
        }
        
        if let firstSubview = contentView.subviews.first {
            firstSubview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        }
        
        if let lastSubview = contentView.subviews.last {
            lastSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
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
        let gitHubUrl = URL(string: "https://github.com/majbyr/komi-keyboard-ios")
        UIApplication.shared.open(gitHubUrl!)
    }
    
    @objc private func openWebsite() {
        // Implementation to open Website link
        let websiteUrl = URL(string: "https://majbyr.com/")
        UIApplication.shared.open(websiteUrl!)
    }
}
