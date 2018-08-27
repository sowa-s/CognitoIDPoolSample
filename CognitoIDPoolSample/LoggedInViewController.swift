import UIKit
import AWSCore
import AWSDynamoDB

class LoggedInViewController: UIViewController {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var userIdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresh()
    }
    
    func refresh() {
        CognitoClient.sharedInstance.fetchId().continueWith { task -> Any? in
            DispatchQueue.main.async {
                if let error = task.error {
                    self.showAlert(title: "ERROR", message: error.localizedDescription)
                }
                if let id = task.result {
                    self.idLabel.text = id as String
                    self.userIdField.text = id as String
                }
            }
            return nil
        }
    }

    @IBAction func tapFetchDynamoDB(_ sender: Any) {
        
        let dynamoDB = AWSDynamoDB.default()
        let input = AWSDynamoDBGetItemInput()
        input?.tableName = Constant.dynamoDBTableName
        
        let value = AWSDynamoDBAttributeValue()
        value?.s = userIdField.text
        input?.key = ["userid": value!]
        
        dynamoDB.getItem(input!).continueWith { task -> Any? in
            if let items = task.result?.item {
                let message = items.map({ (key: String, value: AWSDynamoDBAttributeValue) -> String in
                    key + ":" + value.s!
                }).joined(separator: "\n")
                DispatchQueue.main.async {
                    self.showAlert(title: "SUCCESS", message: message)
                }
            }
            if let error = task.error {
                DispatchQueue.main.async {
                    self.showAlert(title: "ERROR", message: error.localizedDescription)
                }
            }
            return nil
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion:  nil)
    }
    
    @IBAction func tapSignOut(_ sender: Any) {
        CognitoClient.sharedInstance.signOut()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
