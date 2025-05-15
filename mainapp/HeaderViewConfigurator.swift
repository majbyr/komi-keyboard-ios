import UIKit

class HeaderViewConfigurator {
    let headerView = UIView()
    let appNameLabel = UILabel()
    let navBarView = UIView()
    let navBarTitleLabel = UILabel()
    private var labelFontSizeMax: CGFloat = 34
    private var labelFontSizeMin: CGFloat = 18
    var navBarHeight: CGFloat = 95

    func configureNavBar(in view: UIView) {
        navBarView.backgroundColor = .systemBackground
        navBarView.layer.zPosition = 10
        navBarView.alpha = 0
        view.addSubview(navBarView)
        navBarTitleLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        navBarTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        navBarTitleLabel.textAlignment = .center
        navBarView.addSubview(navBarTitleLabel)
        let navBarBottomBorder = UIView()
        navBarBottomBorder.backgroundColor = UIColor.separator
        navBarView.addSubview(navBarBottomBorder)
        navBarBottomBorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navBarBottomBorder.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor),
            navBarBottomBorder.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor),
            navBarBottomBorder.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor),
            navBarBottomBorder.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        navBarTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navBarView.topAnchor.constraint(equalTo: view.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarView.heightAnchor.constraint(equalToConstant: navBarHeight),
            navBarTitleLabel.centerXAnchor.constraint(equalTo: navBarView.centerXAnchor),
            navBarTitleLabel.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor, constant: -10)
        ])
    }

    func configureHeaderInContentView() {
        appNameLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        appNameLabel.font = UIFont.systemFont(ofSize: labelFontSizeMax, weight: .bold)
        appNameLabel.textAlignment = .left
        headerView.addSubview(appNameLabel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            appNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            appNameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
    }
}
