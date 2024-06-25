// UIColor+Extensions.swift

import UIKit

extension UIColor {
    static let lightActionButton: UIColor = UIColor(red: 172.0 / 255, green: 177.0 / 255, blue: 185.0 / 255, alpha: 1)
    static let darkButton       : UIColor = UIColor(red: 255.0 / 255, green: 255.0 / 255, blue: 255.0 / 255, alpha: 0.333)
    static let darkActionButton : UIColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 0.28)
    static let darkPopup        : UIColor = UIColor(red: 112.0 / 255, green: 112.0 / 255, blue: 112.0 / 255, alpha: 1)
    
    static let outlineColor     : UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

    
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicKeyColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .darkButton : .white
    }
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicActionKeyColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .darkActionButton : .lightActionButton
    }
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicTextColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicShadowColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .black : .gray
    }
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicHintColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .lightGray : .gray
    }
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicPopupColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .darkPopup : .white
    }
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicBackgroundColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .black : .systemGray6
    }
    @available(iOSApplicationExtension 13.0, *)
    static let dynamicFieldColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .systemGray6 : .white
    }
}
