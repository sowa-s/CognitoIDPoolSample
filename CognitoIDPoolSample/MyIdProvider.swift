import AWSCognitoIdentityProvider
import FBSDKCoreKit
import FBSDKLoginKit

class MyIdProvider: NSObject, AWSIdentityProviderManager {
    
    let userpool: AWSCognitoIdentityUserPool
    
    init(userpool: AWSCognitoIdentityUserPool) {
        self.userpool = userpool
    }
    
    func logins() -> AWSTask<NSDictionary> {
        if let user = self.userpool.currentUser() {
            if user.isSignedIn {
                return self.userpool.currentUser()?.getSession().continueOnSuccessWith(block: { task -> NSDictionary? in
                    if let token = task.result?.idToken?.tokenString {
                        return [self.userpool.identityProviderName: token]
                    }
                    return NSDictionary.init()
                }) as! AWSTask<NSDictionary>
            }
        }
        
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            return AWSTask(result: [AWSIdentityProviderFacebook: FBSDKAccessToken.current().tokenString])
        }
        
        let _ = self.userpool.currentUser()?.getDetails()
        return AWSTask(error: NSError.init(domain: "FAILED", code: 1, userInfo: nil))
    }
}
