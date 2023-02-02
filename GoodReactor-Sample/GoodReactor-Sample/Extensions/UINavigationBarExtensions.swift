//
//  UINavigationBarExtensions.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit

extension UINavigationBar {

    static func configureAppearance() {
        let appearance = self.appearance()
        appearance.prefersLargeTitles = true
        appearance.tintColor = .black
    }

}

