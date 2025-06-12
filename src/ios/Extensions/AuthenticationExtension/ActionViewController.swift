import PassKit
import SwiftUI
import UIKit

class ActionViewController: UIViewController, PKIssuerProvisioningExtensionAuthorizationProviding {
    var completionHandler: ((PKIssuerProvisioningExtensionAuthorizationResult) -> Void)?
    var activityIndicator: UIActivityIndicatorView!
    // var hostingController: UIHostingController<LoginActivity>?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoadingIndicator()
        // showSwiftUIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /**********************************
         authenticate() - if you want use uikit
        ***********************************/
    }

    /** - Enable if compiled with Wallet extension
    func showSwiftUIView() {
        let loginView = LoginActivity() { token in
            print("jwt -> \(token)")
            self.hostingController?.willMove(toParent: nil)
            self.hostingController?.view.removeFromSuperview()
            self.hostingController = nil
            self.dismiss(animated: true)
            self.completionHandler?(.authorized)
        }
        let controller = UIHostingController(rootView: loginView)
        self.hostingController = controller

        print("jwt success \(String(describing: hostingController?.rootView.onLoginSuccess))")

        controller.view.frame = self.view.bounds
                controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                addChildViewController(controller)
                view.addSubview(controller.view)
                controller.didMove(toParent: self)
        }
     */

    func setupLoadingIndicator() {
            print("auth1 setupLoadingIndicator")
            view.backgroundColor = .systemBackground

            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .large)
            activityIndicator.color = .gray
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activityIndicator)

            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])

            activityIndicator.startAnimating()
        }

    func authenticate() {
        BiometricUtility.shared.checkBiometricAuthorization { isAuthorized, _ in
        print("auth2 authenticate: \(isAuthorized)")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            if isAuthorized {
                self.completionHandler?(.authorized)
            } else {
                self.completionHandler?(.canceled)
            }
        }
    }
}
