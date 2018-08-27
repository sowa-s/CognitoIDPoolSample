import AWSCore
import AWSCognitoIdentityProvider
import FBSDKCoreKit
import FBSDKLoginKit

class CognitoClient {
    static let sharedInstance = CognitoClient()
    
    let userPool: AWSCognitoIdentityUserPool
    let credentialProvider: AWSCognitoCredentialsProvider

    private init() {
        var configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider: nil)
        
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
            clientId: Constant.clientId,
            clientSecret: Constant.clientSecret,
            poolId: Constant.poolId)
        
        AWSCognitoIdentityUserPool.register(
            with: configuration,
            userPoolConfiguration: userPoolConfiguration,
            forKey: "CognitoUserPool")
        
        userPool = AWSCognitoIdentityUserPool(forKey: "CognitoUserPool")
        userPool.delegate = UIApplication.shared.delegate as! AWSCognitoIdentityInteractiveAuthenticationDelegate
        
        let myIdProvider = MyIdProvider(userpool: userPool)
        
        credentialProvider = AWSCognitoCredentialsProvider(
            regionType: .APNortheast1,
            identityPoolId: Constant.identityPoolId,
            identityProviderManager: myIdProvider)
        
        configuration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: self.credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func signOut() {
        credentialProvider.clearCredentials()
        credentialProvider.clearKeychain()
        userPool.currentUser()?.signOut()
        FBSDKLoginManager().logOut()
        let _ = userPool.currentUser()?.getDetails()
    }
    
    func fetchId() -> AWSTask<NSString> {
        return CognitoClient.sharedInstance.credentialProvider.getIdentityId()
    }
}
