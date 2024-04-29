import UIKit

extension UIButton {
    static func createSystemButton(withTitle title: String, imageSystemName imageName: String, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        
        // Setup the primary image
        var mainImageView: UIImageView?
        if let originalImage = UIImage(named: imageName)?.resized(to: CGSize(width: 30, height: 30)) {
            mainImageView = UIImageView(image: originalImage)
            mainImageView?.contentMode = .scaleAspectFit
            mainImageView?.translatesAutoresizingMaskIntoConstraints = false
            mainImageView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
            mainImageView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        // Setup the arrow image
        let arrowImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.tintColor = .systemGray2
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        
        // Setup the label
        let label = UILabel()
        label.text = title
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 15)
        
        // Setup stack view containing the images and label
        let stackView = UIStackView(arrangedSubviews: [mainImageView, label, arrowImageView].compactMap { $0 })
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        
        button.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -10)
        ])
        
        // Setup the underline view
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGray3
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            underlineView.heightAnchor.constraint(equalToConstant: 0.3),
            underlineView.leadingAnchor.constraint(equalTo: mainImageView!.trailingAnchor, constant: 10),
            underlineView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            underlineView.topAnchor.constraint(equalTo: button.topAnchor, constant: -1)
        ])
        
        // Add target action
        button.addTarget(target, action: action, for: .touchUpInside)
        
        return button
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

extension UIStackView {
    func configureAsVerticalStack(withSpacing spacing: CGFloat) {
        //        self.backgroundColor = .green
        self.axis = .vertical
        self.distribution = .fillEqually
        self.spacing = spacing
        self.layer.cornerRadius = 10
        self.backgroundColor = .systemGray6
        self.clipsToBounds = true
        
    }
}

extension UIFont {
    /// Returns a bold version of the preferred font for the specified text style.
    func bold() -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(.traitBold) ?? UIFontDescriptor()
        return UIFont(descriptor: descriptor, size: 0)
    }
}
