// 
//  AboutViewController.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit
import Combine

final class AboutViewController: BaseViewController<AboutViewModel>  {

    private enum C {

        static let spacing: CGFloat = 16

    }

    // MARK: - Constants

    private let aboutStackView: UIStackView = {
        let aboutStackView = UIStackView()
        aboutStackView.translatesAutoresizingMaskIntoConstraints = false
        aboutStackView.axis = .vertical
        aboutStackView.spacing = C.spacing
        aboutStackView.alignment = .center

        return aboutStackView
    }()

    private let bottomStackView: UIStackView = {
        let bottomStackView = UIStackView()
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .vertical
        bottomStackView.spacing = C.spacing
        bottomStackView.distribution = .fillProportionally

        return bottomStackView
    }()

    private let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "goodRequest")

        return logoImageView
    }()

    private let appLabel: MultiLineLabel = {
        MultiLineLabel.create(
            text: Constants.Texts.About.App.name,
            font: .systemFont(ofSize: 18, weight: .semibold),
            alignment: .center
        )
    }()

    private let descriptionLabel: UILabel = {
        MultiLineLabel.create(text: Constants.Texts.About.App.description, alignment: .center)
    }()

    private let developerLabel: UILabel = {
        MultiLineLabel.create(text: Constants.Texts.About.App.developer, alignment: .center)
    }()

    private let documentationButton: ActionButton = {
        let documentationButton = ActionButton()
        documentationButton.setTitle(Constants.Texts.About.documentation, for: .normal)

        return documentationButton
    }()

    private let aboutUsButton: ActionButton = {
        let aboutUsButton = ActionButton()
        aboutUsButton.setTitle(Constants.Texts.About.aboutUs, for: .normal)

        return aboutUsButton
    }()

}

// MARK: - Lifecycle

extension AboutViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        bindState(reactor: viewModel)
        bindActions(reactor: viewModel)
    }

}

// MARK: - Setup

private extension AboutViewController {

    func setupLayout() {
        view.backgroundColor = UIColor(named: "background")
        title = Constants.Texts.About.title

        [logoImageView, appLabel, descriptionLabel, developerLabel].forEach { aboutStackView.addArrangedSubview($0) }
        [documentationButton, aboutUsButton].forEach { bottomStackView.addArrangedSubview($0) }

        view.addSubview(aboutStackView)
        view.addSubview(bottomStackView)

        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            aboutStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.spacing),
            aboutStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.spacing),
            aboutStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.spacing * 2),

            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),

            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.spacing),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.spacing),
            bottomStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -C.spacing
            )
        ])
    }

}

// MARK: - Combine

private extension AboutViewController {

    func bindState(reactor: AboutViewModel) {}

    func bindActions(reactor: AboutViewModel) {
        Publishers.Merge(
            documentationButton.publisher(for: .touchUpInside).map { _ in .goToDocumentation },
            aboutUsButton.publisher(for: .touchUpInside).map { _ in .goToAboutUs }
        )
        .subscribe(reactor.action)
        .store(in: &cancellables)
    }

}
