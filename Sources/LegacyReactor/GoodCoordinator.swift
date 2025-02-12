//
//  GoodCoordinator.swift
//  GoodReactor
//
//  Created by Matúš Mištrik on 22/01/2025.
//

import Combine
import UIKit
import MessageUI
import SafariServices

// MARK: - StepAction

public enum StepAction {

    // Navigation
    case push(UIViewController)
    case pushWithCompletion(UIViewController, @MainActor () -> ())
    case pop
    case popTo(UIViewController)
    case popToRoot

    // Modal
    case present(UIViewController, UIModalPresentationStyle = .automatic, UIViewControllerTransitioningDelegate? = nil)
    case dismiss
    case dismissWithCompletion(@MainActor () -> ())

    // Automatic
    /// Pop or dismiss automatically
    case close
    case set([UIViewController])

    // Links
    case safari(URL, UIModalPresentationStyle = .automatic, tintColor: UIColor? = nil)
    case universalLink(url: URL, onlyUniversal: Bool, completion: (@MainActor (Bool) -> ())? = nil)

    // Actions
    case call(String)
    case sms(messageModel: MessageComposer.MessageModel, onError: @MainActor () -> ())
    case mail(mailModel: MessageComposer.MailModel, onError: @MainActor () -> ())
    case mailInbox

    // System apps
    case openSettings
    case openMessages
    case none

    public var isModalAction: Bool {
        switch self {
        case .present, .dismiss, .dismissWithCompletion, .safari, .universalLink, .call, .sms, .mail, .mailInbox, .openSettings, .openMessages, .close:
            return true

        default:
            return false
        }
    }

    public var isNavigationAction: Bool {
        switch self {
        case .push, .pushWithCompletion, .pop, .popTo, .set, .popToRoot, .close:
            return true

        default:
            return false
        }
    }

}

///GoodCoordinator is used for managing navigation flow and data flow between different parts of an app.
///It is a generic class that takes a Step type as its generic parameter.
@available(iOS 13.0, *)
open class GoodCoordinator<Step>: NSObject, Coordinator {

    open var cancellables: Set<AnyCancellable> = Set()

    open var children = NSPointerArray.weakObjects()

    open var parentCoordinator: Coordinator?

    @Published open var step: Step?

    open weak var rootViewController: UIViewController?

    // MARK: - Initialization

    /// Initializes a GoodCoordinator with a given root view controller and an optional parent coordinator. If a parent coordinator is provided, the current instance is automatically added to the parent’s children collection.
    /// - Parameters:
    ///   - rootViewController: The root view controller managed by this coordinator. Default value is nil.
    ///   - parentCoordinator: The parent coordinator of this coordinator. Default value is nil.
    public required init(rootViewController: UIViewController? = nil) {
        super.init()

        self.rootViewController = rootViewController
    }
    
    /// A convenience initializer that initializes a GoodCoordinator with a root view controller derived from the provided parent coordinator.
    /// - Parameter parentCoordinator: The parent coordinator to which this coordinator will belong.
    public required init(parentCoordinator: Coordinator?) {
        super.init()

        self.parentCoordinator = parentCoordinator
        self.rootViewController = parentCoordinator?.rootViewController
        self.parentCoordinator?.children.addObject(self)
    }

    // MARK: - Overridable

    @discardableResult
    open func navigate(to stepper: Step) -> StepAction {
        return .none
    }

    // MARK: - Navigation

    @discardableResult
    open func start() -> UIViewController? {
        startHeadless()

        return rootViewController
    }

    @discardableResult
    public final func startHeadless() -> Self {
        $step
            .compactMap { $0 }
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.navigate(action: self.navigate(to: $0))
            }.store(in: &cancellables)

        return self
    }

    private func navigate(action: StepAction) {
        do {
            if action.isModalAction == true {
                try handleModalAction(action)
            } else if action.isNavigationAction == true {
                try handleFlowAction(action)
            } else {
                print("⛔️ Navigation action failed: neither isModalAction nor isNavigationAction is specified")
            }
        } catch(let error) {
            print("⛔️ Navigation action failed: \(error.localizedDescription)")
        }
    }

    public func perform(step: Step) {
        self.step = step
    }

    // MARK: - Navigation - Static

    public static func execute<S, C: GoodCoordinator<S>>(
        step: S,
        on coordinator: C.Type,
        from parent: Coordinator
    ) {
        guard Thread.isMainThread else {
            print("⚠️ Attempted to execute UI navigation from background thread! Switching to main...")
            return DispatchQueue.main.async { Self.execute(step: step, on: coordinator, from: parent) }
        }

        if let coordinator = parent.lastChildOfType(type: coordinator) {
            coordinator.perform(step: step)
        } else {
            parent.resetChildReferences()

            let coordinator = coordinator.init(parentCoordinator: parent)
            coordinator.startHeadless().perform(step: step)
        }
    }

}

// MARK: - Action Handling

private extension GoodCoordinator {

    // MARK: - Modal actions

    func handleModalAction(_ action: StepAction) throws {
        guard let viewController = rootViewController else {
            throw CoordinatorError.missingRoot(description: "Coordinator without root view controller")
        }

        switch action {
        case .close:
            do {
                try handleFlowAction(.pop)
            } catch {
                fallthrough
            }

        case .dismiss:
            var topController = viewController
            while let newTopController = topController.presentedViewController {
                topController = newTopController
            }

            topController.dismiss(animated: true)

        case .dismissWithCompletion(let completion):
            var topController = viewController
            while let newTopController = topController.presentedViewController {
                topController = newTopController
            }

            topController.dismiss(animated: true, completion: completion)

        case .present(let controller, let style, let transitionDelegate):
            present(
                transitionDelegate: transitionDelegate,
                controller: controller,
                style: style,
                viewController: viewController
            )

        case .safari(let url, let style, let tintColor):
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.preferredControlTintColor = tintColor
            safariViewController.modalPresentationStyle = style

            present(
                transitionDelegate: nil,
                controller: safariViewController,
                style: style,
                viewController: viewController
            )

        case .universalLink(let url, let universalOnly, let completion):
            UIApplication.shared.open(url, options: [.universalLinksOnly : universalOnly], completionHandler: completion)

        case .call(let number):
            if let telprompt = URL(string: "telprompt://\(number.components(separatedBy: .whitespacesAndNewlines).joined())") {
                UIApplication.shared.open(telprompt)
            }

        case .sms(let model, let onError):
            sms(model: model, viewController: viewController, onError: onError)

        case .mail(let model, let onError):
            mail(model: model, viewController: viewController, onError: onError)

        case .mailInbox:
            mailInbox()

        case .openSettings:
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }

        case .openMessages:
            if let messagesUrl = URL(string: "sms://open?message-guid=0") {
                UIApplication.shared.open(messagesUrl)
            }

        default:
            break
        }
    }

    func present(
        transitionDelegate: UIViewControllerTransitioningDelegate?,
        controller: UIViewController,
        style: UIModalPresentationStyle,
        viewController: UIViewController
    ) {
        if let transitionDelegate = transitionDelegate {
            controller.transitioningDelegate = transitionDelegate
        }
        controller.modalPresentationStyle = style

        var topController = viewController
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        topController.present(controller, animated: true, completion: nil)
    }

    func sms(model: MessageComposer.MessageModel, viewController: UIViewController, onError: () -> Void) {
        if let messageComposeViewController = MessageComposer.shared.createSMS(model: model) {
            viewController.present(messageComposeViewController, animated: true, completion: nil)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            onError()
        }
    }

    func mail(model: MessageComposer.MailModel, viewController: UIViewController, onError: () -> Void) {
        if let mailComposeViewController = MessageComposer.shared.createMail(model: model) {
            viewController.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            onError()
        }
    }

    func mailInbox() {
        if let mailClientURL = URL(string: "airmail://"), UIApplication.shared.canOpenURL(mailClientURL) {
            UIApplication.shared.open(mailClientURL)

        } else if let mailClientURL = URL(string: "googlegmail://"), UIApplication.shared.canOpenURL(mailClientURL) {
            UIApplication.shared.open(mailClientURL)

        } else if let mailClientURL = URL(string: "readdle-spark://"), UIApplication.shared.canOpenURL(mailClientURL) {
            UIApplication.shared.open(mailClientURL)

        } else if let mailClientURL = URL(string: "ms-outlook://"), UIApplication.shared.canOpenURL(mailClientURL) {
            UIApplication.shared.open(mailClientURL)

        } else if let mailClientURL = URL(string: "ymail://"), UIApplication.shared.canOpenURL(mailClientURL) {
            UIApplication.shared.open(mailClientURL)

        } else if let mailClientURL = URL(string: "message://"), UIApplication.shared.canOpenURL(mailClientURL) {
            UIApplication.shared.open(mailClientURL)
        }
    }

}

private extension Coordinator {

    // MARK: - Flow actions

    func handleFlowAction(_ action: StepAction) throws {
        guard let navigationController = rootNavigationController else {
            throw CoordinatorError.missingRoot(description: "Coordinator without navigation view controller")
        }

        switch action {
        case .push(let controller):
            navigationController.pushViewController(controller, animated: true)

        case .pushWithCompletion(let controller, let completion):
            navigationController.pushViewController(controller, animated: true)

            guard let coordinator = navigationController.transitionCoordinator else {
                completion()
                return
            }

            coordinator.animate(alongsideTransition: nil) { _ in completion() }

        case .pop:
            navigationController.popViewController(animated: true)

        case .popTo(let controller):
            navigationController.popToViewController(controller, animated: true)

        case .popToRoot:
            navigationController.popToRootViewController(animated: true)

        case .set(let controllers):
            navigationController.setViewControllers(controllers, animated: true)

//        case .benuWeb(let url, _):
//            let controller = BenuWebViewController(url: url)
//            viewController.pushViewController(controller, animated: true)

        default:
            break
        }
    }

}

// MARK: - Messages

@MainActor public final class MessageComposer: NSObject, Sendable {

    public struct MailModel {

        public let addresses: [String]
        public let subject: String
        public let message: String
        public let isHtml: Bool

        public init(addresses: [String], subject: String, message: String, isHtml: Bool) {
            self.addresses = addresses
            self.subject = subject
            self.message = message
            self.isHtml = isHtml
        }

    }

    public struct MessageModel {

        public let numbers: [String]
        public let message: String

        public init(numbers: [String], message: String) {
            self.numbers = numbers
            self.message = message
        }

    }

    fileprivate static let shared = MessageComposer()

    private override init() {}

    fileprivate func createMail(model: MailModel) -> MFMailComposeViewController? {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(model.addresses)
            mailComposer.setSubject(model.subject)
            mailComposer.setMessageBody(model.message, isHTML: model.isHtml)

            return mailComposer
        } else {
            if let addresses = model.addresses.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let subject = model.subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let message = model.message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let mailtoURL = URL(string: "mailto:\(addresses)&subject=\(subject)&body=\(message)"),
               UIApplication.shared.canOpenURL(mailtoURL) {

                UIApplication.shared.open(mailtoURL)
            }
        }
        return nil
    }

    fileprivate func createSMS(model: MessageModel) -> MFMessageComposeViewController? {
        if MFMessageComposeViewController.canSendText() {
            let messageComposer = MFMessageComposeViewController()
            messageComposer.messageComposeDelegate = self
            messageComposer.recipients = model.numbers
            messageComposer.body = model.message

            return messageComposer
        }
        return nil
    }

}

extension MessageComposer: MFMailComposeViewControllerDelegate {

    nonisolated public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        MainActor.assumeIsolated {
            controller.dismiss(animated: true)
        }
    }

}

extension MessageComposer: MFMessageComposeViewControllerDelegate {

    nonisolated public func messageComposeViewController(
        _ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult
    ) {
        MainActor.assumeIsolated {
            controller.dismiss(animated: true)
        }
    }

}

// MARK: - CoordinatorError

enum CoordinatorError: Error {

    case missingRoot(description: String)

}
