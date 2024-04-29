import UIKit

class MenuStackView: UIView {
    private let titleLabel = UILabel()
    private let hintLabel = UILabel()
    private let buttonsStackView = UIStackView()

    // Initializer that sets up the menu stack view
    init(title: String, hint: String, buttonDetails: [(title: String, imageName: String, target: Any?, action: Selector)]) {
        super.init(frame: .zero)
        configureTitleLabel(title)
        configureButtonsStack(buttonDetails)
        configureHintLabel(hint)
        setupLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureTitleLabel(_ title: String) {
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .systemGray
        addSubview(titleLabel)
    }

    private func configureButtonsStack(_ details: [(title: String, imageName: String, target: Any?, action: Selector)]) {
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.alignment = .fill
        buttonsStackView.spacing = 0
        buttonsStackView.layer.cornerRadius = 10
        buttonsStackView.backgroundColor = .systemGray6
        buttonsStackView.clipsToBounds = true

        for detail in details {
            let button = UIButton.createSystemButton(withTitle: detail.title, imageSystemName: detail.imageName, target: detail.target, action: detail.action)
            buttonsStackView.addArrangedSubview(button)
        }
        addSubview(buttonsStackView)
    }

    private func configureHintLabel(_ hint: String) {
        hintLabel.text = hint
        hintLabel.font = .preferredFont(forTextStyle: .caption1)
        hintLabel.textAlignment = .left
        hintLabel.numberOfLines = 0
        hintLabel.textColor = .systemGray
        addSubview(hintLabel)
    }

    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            buttonsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 10),
            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
