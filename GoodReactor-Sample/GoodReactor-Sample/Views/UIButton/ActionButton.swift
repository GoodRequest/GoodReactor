//
//  ActionButton.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit

class ActionButton: UIButton {

    // MARK: - Enum

    enum Appearance {

        case fill
        case empty

    }

    // MARK: - Constant

    private enum C {

        static let cornerRadius = CGFloat(28)
        static let height = CGFloat(56)
        static let spacing = CGFloat(8)

    }

    private var shadowLayer: CAShapeLayer!

    // MARK: - Model

    struct Model {

        var title: String
        var image: UIImage? = nil
        var appearance: Appearance = .fill

    }

    // MARK: - Variables

    override var isHighlighted: Bool {
        didSet {
            animate(isHighlighted: isHighlighted)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: C.height).isActive = true
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        setTitleColor(.black, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setup(_ model: Model) {
        setTitle(model.title, for: .normal)
    }

}
