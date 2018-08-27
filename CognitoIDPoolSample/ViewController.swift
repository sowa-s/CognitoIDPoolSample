import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AWSCognitoIdentityProvider

class ViewController: UIViewController {

    @IBOutlet weak var useridField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookButton.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signin(_ sender: Any) {
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: useridField.text!, password: passwordField.text!)
        passwordAuthenticationCompletion?.set(result: authDetails)
    }
}

extension ViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.dismiss(animated: true) {
            if let vc = UIApplication.shared.delegate?.window??.rootViewController as? LoggedInViewController {
                vc.refresh()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) { }
}
extension ViewController: AWSCognitoIdentityPasswordAuthentication {
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true) {
                    if let vc = UIApplication.shared.delegate?.window??.rootViewController as? LoggedInViewController {
                        vc.refresh()
                    }
                }
            }
        }
    }
    
}


