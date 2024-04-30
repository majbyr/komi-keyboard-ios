// KeyboardView.swift

import UIKit

class KeyboardView: UIView {

    weak var delegate: KeyDelegate?
    
    private let keyboarHeight: CGFloat = Calculator.getKeyboardHeight()
    
    var rows: [KeyRow] = []

    
    init(layout: KeyboardLayouts, delegate: KeyDelegate?, includeGlobeKey: Bool = true) {
        super.init(frame: .zero)
        self.delegate = delegate
        let biggestRowLength = layout.keys.map { $0.count }.max() ?? 0
        self.rows = layout.keys.map { keys in
            let filteredKeys = includeGlobeKey ? keys : keys.filter { $0 != "globe" }
            return KeyRow(keys: filteredKeys,
                          delegate: delegate,
                          biggestRowLength: biggestRowLength,
                          hints: layout.hints,
                          subkeys: layout.subchars)
        }
        setupKeyboardView()
    }
    
    private func setupKeyboardView() {
        var previousRow: UIView?
        for row in rows {
            
            row.delegate = delegate
            addSubview(row)
            row.translatesAutoresizingMaskIntoConstraints = false
            
            // Set constraints for each row
            NSLayoutConstraint.activate([
                row.leftAnchor.constraint(equalTo: leftAnchor),
                row.rightAnchor.constraint(equalTo: rightAnchor),
                row.heightAnchor.constraint(equalToConstant: keyboarHeight / CGFloat(rows.count))
            ])

            if let previousRow = previousRow {
                // Position this row below the previous row
                row.topAnchor.constraint(equalTo: previousRow.bottomAnchor).isActive = true
            } else {
                // This is the first row, position it at the top of the keyboard view
                row.topAnchor.constraint(equalTo: topAnchor).isActive = true
            }

            previousRow = row
        }

        // Constraint for the last row to the bottom anchor of the keyboard view
        rows.last?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
