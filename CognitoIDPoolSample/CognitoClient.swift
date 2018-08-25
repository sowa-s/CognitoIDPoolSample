import AWSCore
import AWSCognitoIdentityProvider

class CognitoClient {
    static let sharedInstance = CognitoClient()
    
    let userPool: AWSCognitoIdentityUserPool
    let credentialProvider: AWSCognitoCredentialsProvider
    
    private init() {
        
        userPool = AWSCognitoIdentityUserPool(forKey: "CognitoUserPool")
        
        credentialProvider = AWSCognitoCredentialsProvider(
            regionType: .APNortheast1,
            identityPoolId: Constant.identityPoolId,
            identityProviderManager: self.userPool)
        
        let configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider:credentialProvider)
        
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
            clientId: Constant.clientId,
            clientSecret: Constant.clientSecret,
            poolId: Constant.poolId)
        AWSCognitoIdentityUserPool.register(
            with: configuration,
            userPoolConfiguration: userPoolConfiguration,
            forKey: "CognitoUserPool")
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}
