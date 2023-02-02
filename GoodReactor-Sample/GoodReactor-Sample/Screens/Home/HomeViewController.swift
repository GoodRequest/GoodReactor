// 
//  HomeViewController.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit
import Combine

final class HomeViewController: BaseViewController<HomeViewModel>  {

    // MARK: - Constants

    private let actionsStackView: UIStackView = {
        let actionsStackView = UIStackView()
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.spacing = 16
        actionsStackView.distribution = .fillEqually
        actionsStackView.axis = .vertical
        return actionsStackView
    }()

    private let counterValueLabel: UILabel = {
        let counterValueLabel = MultiLineLabel.create(
            font: .systemFont(ofSize: 128, weight: .heavy),
            alignment: .center
        )
        counterValueLabel.translatesAutoresizingMaskIntoConstraints = false

        return counterValueLabel
    }()

    private let increasingButton: ActionButton = {
        let button = ActionButton()
        button.setTitle(Constants.Texts.Home.increase, for: .normal)

        return button
    }()

    private let decreasingButton: ActionButton = {
        let button = ActionButton()
        button.setTitle(Constants.Texts.Home.decrease, for: .normal)

        return button
    }()

    private let aboutAppButton: ActionButton = {
        let aboutAppButton = ActionButton()
        aboutAppButton.setTitle(Constants.Texts.Home.aboutApp, for: .normal)

        return aboutAppButton
    }()

}

// MARK: - Lifecycle

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        bindState(reactor: viewModel)
        bindActions(reactor: viewModel)
    }

}

// MARK: - Setup

private extension HomeViewController {
    func setupLayout() {
        view.backgroundColor = UIColor(named: "background")
        title = Constants.Texts.Home.title

        [increasingButton, decreasingButton, aboutAppButton].forEach{ actionsStackView.addArrangedSubview($0) }
        [counterValueLabel, actionsStackView].forEach { view.addSubview($0) }

        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            counterValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterValueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),

            actionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

}

// MARK: - Combine

private extension HomeViewController {

    func bindState(reactor: HomeViewModel) {
        reactor.state
            .map { String($0.counterValue) }
            .removeDuplicates()
            .assign(to: \.text, on: counterValueLabel, ownership: .weak)
            .store(in: &cancellables)

    }

    func bindActions(reactor: HomeViewModel) {
        Publishers.Merge3(
            increasingButton.publisher(for: .touchUpInside).map { _ in .updateCounterValue(.increase) },
            decreasingButton.publisher(for: .touchUpInside).map { _ in .updateCounterValue(.decrease) },
            aboutAppButton.publisher(for: .touchUpInside).map { _ in .goToAbout }
        )
        .subscribe(reactor.action)
        .store(in: &cancellables)
    }

}
