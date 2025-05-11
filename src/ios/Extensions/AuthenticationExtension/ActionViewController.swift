import PassKit
import UIKit

class ActionViewController: UIViewController, PKIssuerProvisioningExtensionAuthorizationProviding {
    var completionHandler: ((PKIssuerProvisioningExtensionAuthorizationResult) -> Void)?
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        authenticate()
    }

    func setupLoadingIndicator() {
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
