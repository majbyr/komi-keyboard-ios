import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    var headerConfigurator: HeaderViewConfigurator!
    var headerHeightConstraint: NSLayoutConstraint!
    let maxHeaderHeight: CGFloat = 80
    let minHeaderHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupScrollView()
        configureUI()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        headerConfigurator = HeaderViewConfigurator()
        headerConfigurator.configureNavBar(in: view)
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        headerConfigurator.configureHeaderInContentView()
        contentView.addSubview(headerConfigurator.headerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func configureUI() {
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
        headerHeightConstraint = headerConfigurator.headerView.heightAnchor.constraint(equalToConstant: maxHeaderHeight)
        headerHeightConstraint.isActive = true
        headerConfigurator.headerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        headerConfigurator.headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        headerConfigurator.headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        var previousSubview: UIView? = headerConfigurator.headerView
        for subview in contentView.subviews where subview != headerConfigurator.headerView {
            subview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                subview.topAnchor.constraint(equalTo: previousSubview!.bottomAnchor, constant: 30),
                subview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                subview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])
            previousSubview = subview
        }
        if let lastSubview = contentView.subviews.last {
            lastSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }

    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fadeDistance: CGFloat = 10
        let fadePercent = min(1, max(0, scrollView.contentOffset.y / fadeDistance))
        headerConfigurator.navBarView.alpha = fadePercent
    }

    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let bottomInset = keyboardHeight - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = bottomInset
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        } else {
            scrollView.scrollIndicatorInsets.bottom = bottomInset
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        } else {
            scrollView.scrollIndicatorInsets.bottom = 0
        }
    }

    // MARK: - Actions for Settings and Links
    @objc private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    @objc private func openAppStore() {
        let appStoreUrl = URL(string: "https://apps.apple.com/us/developer/aleksei-ivanov/id1536776623")
        UIApplication.shared.open(appStoreUrl!)
    }
    @objc private func openGitHub() {
        let gitHubUrl = URL(string: "https://github.com/majbyr/komi-keyboard-ios")
        UIApplication.shared.open(gitHubUrl!)
    }
    @objc private func openWebsite() {
        let websiteUrl = URL(string: "https://majbyr.com/")
        UIApplication.shared.open(websiteUrl!)
    }
}
