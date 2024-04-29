import UIKit

struct HeaderViewConfigurator {
    private let headerView = UIView()
    private let appNameLabel = UILabel()

    init(view: UIView) {
        configureHeaderView(in: view)
    }

    private func configureHeaderView(in view: UIView) {
        view.addSubview(headerView)
        appNameLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        appNameLabel.font = .preferredFont(forTextStyle: .largeTitle).bold()
        appNameLabel.textAlignment = .left
        headerView.addSubview(appNameLabel)

        setConstraints(in: view)
    }

    private func setConstraints(in view: UIView) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            appNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            appNameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
        ])
    }
}
