---
title: "AWS CDK - Understanding Amazon Cognito Authentication and Authorization"
date: 2023-02-20 12:00:00 -0000
categories: aws devops cdk typescript
---

### Diagram

#### [Amazon Cognito Client Workflow (draw.io viewer)](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=Devops-IaC-AWS_CDK_Cognito.drawio#Uhttps%3A%2F%2Fraw.githubusercontent.com%2FAdam-Lechnos%2Fdiagrams-charts%2Fmain%2Fdevops%2FDevops-IaC-AWS_CDK_Cognito.drawio){:target="_blank" rel="noopener"}

![Amazon Cognito Client Workflow]({{ site.github-content }}/devops/Devops-IaC-AWS_CDK_Cognito.drawio.svg?raw=true)

### The Moving Pieces 
Components of Amazon Cognito which are part of the authentication and authorization flow:

#### Cognito User Pools - Authentication, Authorization, and Resource Servers
* Refer to my blog post, [AWS CDK - Breaking Down AWS Cognito OAuth & OIDC Workflow](/aws/devops/cdk/typescript/2023/03/05/aws-cdk-cognito-workflow.html) for more details about what Authentication, Authorization, and Resource Servers are.
* Contains a directory of users & groups or, may be delegated to a Federated Identity Provider for sign-in experience, such as Google, Facebook, Amazon, Apple, SAML, or OIDC (OpenID Connect).
* Groups created within the User Pool are associated with IAM ([AWS Identity and Access Management](https://aws.amazon.com/iam/)) roles, assumed by the user for performing tasks within AWS, such as reading S3 Buckets.
  * Each group may have a separate IAM Role configured, for allowing delineated permissions amongst disparate [managed group members](https://docs.aws.amazon.com/cognito/latest/developerguide/managing-users.html?icmpid=docs_cognito_console_help_panel).
* App integration settings, where app clients are defined and its token expiration, authentication flows, OAUTH 2.0 grant types, and OpenID Connect Scopes and Identity Providers are defined.
  * Authentication flow options: ALLOW_ADMIN_USER_PASSWORD_AUTH, ALLOW_USER_PASSWORD_AUTH, ALLOW_REFRESH_TOKEN_AUTH, ALLOW_USER_PASSWORD_AUTH, and ALLOW_USER_SRP_AUTH.
  * OAuth 2.0 grant type options: 
    * Authorization code grant - provides an authorization code as the response to be exchanges on a back-channel or server side for a Access Token. The exchange would include a client ID and Client Secret.
    * Implicit grant - specifies that the client should get the access token (and optionally, ID token, based on scopes) directly. (exposes the OAuth (Access) token within the URL)
  * OpenID Connect Scopes - at least one scope is required to specify the attributes the app client can retrieve for access. Scopes include:
    * `aws.cognito.sigin.user.admin`, `openid`, `email`, `phone`, and `profile` (the last three options also require OpenID to be selected)
    * These scopes authorize the access token for retrieval of user attributes from the [userInfo endpoint](https://docs.aws.amazon.com/cognito/latest/developerguide/userinfo-endpoint.html) for OpenID Connect.
  * Identity providers - which are made available to the client. Some or all of your user pool external Identity Providers may be selected to authenticate your users.
    * Selecting at least `Cognito user pool` enables authentication via the Cognito User Pool, which enables access to its Federated Identity Providers, or, its own internal set of users.
  * Adding at least a [Configured User Pool Domain](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-assign-domain.html?icmpid=docs_cognito_console_help_panel) within the App Integration tab provides a Hosted UI for the user sign-in experience.
  * The client is where the Authentication flow session duration, refresh token expiration, access token expiration, ID token expiration, and other advanced authentication settings are specified.

#### Cognito Identity Pools - AWS Resource Access via IAM Assumed Roles
* Grants users access to AWS resources, and are associated with Identity Pools as the Identity Provider. External Identity Providers may be selected here as well, bypassing the use of Amazon Cognito User Pools.
* Default Authenticated and Unauthenticated (Guest Access) roles may be specified, whereby the ID pool is the trusted resource assuming the role on behalf of the user.
* Custom roles may be added then mapped via the user pool and its assigned groups (Admin group members will be assigned the Admin IAM role for example).
  * This mapping would be used either in conjunction or in lieu of the IAM roles associated with groups created within the Cognito User Pools, depending on how the role mappings are configured.
      * Rule based role mappings will match claim values, whereas Token based role mappings will perform a lookup of the IAM Role associated with `cognito:role` and `cognito:preferred_role` claims injected into the ID Token from the Cognito Identity Pool. 
  * Using a Federated Identity Provider within the User Pool would require mapping the custom roles via the claim values to IAM Roles. Rule based role mappings are required. (more on this below)
* The ARN of the assigned user's role get injected into the [ID Token](https://auth0.com/docs/secure/tokens/id-tokens/id-token-structure) as `"cognito:role": [<list of role ARNs>]`.
* In addition, `"cognito:preferred_role":"<role ARN>"` gets injected in the ID Token, based on the role with the best (lowest) precedence value. If there is only one role, this will be the value.
  * i.e., if authenticated, but no group is assigned within the user pool, use the default role associated with the Authenticated settings.

#### AWS Amplify - Authentication Mechanism
* Configure Cognito as the authentication provider
* Present authentication frontend
* Fetch ID Token upon authentication and pass it around where required
* May use its own Federated Provider such as Google, Apple, etc.

### Technical Terms
In Cognito, both *ID Tokens* and *Access Tokens* include a `cognito:groups` claims that contains user group memberships in the Cognito User Pool. Cognito returns both ID Tokens and Access Tokens.

#### Identity Provider (IdP)
* Provides a database of user identities and their details, such as name, email, etc., and may be provided via a federated external provider, such as Google, Facebook, Amazon, Apple, or any OpenID Connect or SAML provider.
* Refer to AWS' developer guide for more info on [Cognito User Pool Identity Providers](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-identity-provider.html).

#### JSON Web Token (JWT)
* A formatted JSON nested object structure, used by both OAuth and OpenID Connect (more on these terms below) for passing data between web components, ensuring data integrity of the contained payload.
* JWT does not encrypt the data (and will generally depend on TLS for data confidentiality).
* JWTs are Signed by the issuer's private key and verified using the issuer's corresponding public key, for the data integrity component.
* Refer to the official [JWT website](https://jwt.io) for more details.

#### ID Tokens
* According to [OpenID Connect (OIDC)](https://auth0.com/docs/secure/tokens/id-tokens/id-token-structure), in JWT format, provides proof of the user's successful authentication.
* Payloads contain claims about the user properties for the target/receiving application.
  * Claims may be the following keys: `aud`, `name`, `email`, `expiration`, and [others](https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims)
  * For Amazon Cognito, claims will also contains:
    * `cogntio:groups`, an array of the names of user pool groups that have your user as a member. Groups can generate a request for a preferred IAM role from and Identity pool.
    * `cognito:preferred_role`, the ARN of IAM role associated with the user's highest priority user pool group.
    * `cognito:username`, the user name of the user within the user pool group
    * `cognito:roles`, an array of the names of the IAM roles associated with the user's groups. Each user pool group can have an IAM role associated with it.
  * Also refer to AWS' developer guide around [ID Tokens](https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-the-id-token.html) for more info.
* Claims are used by the application to help with the user experience, in lieu of using cookies.

##### Example ID Token Payload
```
<header>.{
    "sub": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "cognito:groups": [
        "test-group-a",
        "test-group-b",
        "test-group-c"
    ],
    "email_verified": true,
    "cognito:preferred_role": "arn:aws:iam::111122223333:role/my-test-role",
    "iss": "https://cognito-idp.us-west-2.amazonaws.com/us-west-2_example",
    "cognito:username": "my-test-user",
    "middle_name": "Jane",
    "nonce": "abcdefg",
    "origin_jti": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "cognito:roles": [
        "arn:aws:iam::111122223333:role/my-test-role"
    ],
    "aud": "xxxxxxxxxxxxexample",
    "identities": [
        {
            "userId": "amzn1.account.EXAMPLE",
            "providerName": "LoginWithAmazon",
            "providerType": "LoginWithAmazon",
            "issuer": null,
            "primary": "true",
            "dateCreated": "1642699117273"
        }
    ],
    "event_id": "64f513be-32db-42b0-b78e-b02127b4f463",
    "token_use": "id",
    "auth_time": 1676312777,
    "exp": 1676316377,
    "iat": 1676312777,
    "jti": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "email": "my-test-user@example.com"
}
.<token signature>
```

#### Access Tokens
* Contains claims about the authenticated user, a list of the user's groups, and a list of scopes, via the [OAuth 2.0 Scope](https://www.rfc-editor.org/rfc/rfc6749#section-3.3) specification, in JWT format.
* Access token provider authorization, granting a client application access specific resources and allow specific actions on behalf of the user, as granted by the access token. 
  * For example, authorizing LinkedIn to access X's (Twitter's) APIs for cross posting.
  * Refer to AWS's developer guide for more info regarding [Access Tokens](https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-the-access-token.html)
* Access Tokens will contain the `scope` key, a list of OAuth 2.0 scopes that define what access the token provides. For Amazon Cognito API sign-in, only `aws.cognito.signin.user.admin` is contained within the scope.
* Amazon Cognito Access Tokens will also contain `cognito:groups`, an array of the names of user pool groups that have you as a member, similar to the OIDC Access Token mentioned above.

##### Example Access Token
```
<header>.
{
   "sub":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
   "device_key": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
   "cognito:groups":[
      "testgroup"
   ],
   "iss":"https://cognito-idp.us-west-2.amazonaws.com/us-west-2_example",
   "version":2,
   "client_id":"xxxxxxxxxxxxexample",
   "origin_jti":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
   "event_id":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
   "token_use":"access",
   "scope":"phone openid profile resourceserver.1/appclient2 email",
   "auth_time":1676313851,
   "exp":1676317451,
   "iat":1676313851,
   "jti":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
   "username":"my-test-user"
}
.<token signature>
```

#### Sample CDK Code
Imagine if we were creating resources using CDK, and wanted to then create an Authentication Stack in order to provide authentication and authorization mechanisms for accessing these resources in AWS. Perhaps we would like to employ a token header for API access, and based on the token, claims about the user will be used in order to determine appropriate permissions. Suppose we would only grant `PUT` access to Admin users, but `GET` is always available to all users. Suppose also 

##### Breaking Down The CDK Constructs
<!-- Refer to the [GitHub Gist](https://gist.github.com/Adam-Lechnos/52b57ccebb82360c606b82d694f74d05), containing the complete CDK for the hypothetical Authentication Stack, written in TypeScript. Here is the breakdown: -->
{% gist 52b57ccebb82360c606b82d694f74d05 %}

##### Create User Pool
``` typescript
private createUserPool(){
    this.userPool = new UserPool(this, 'UserPool', {
        selfSignUpEnabled: true,
        signInAliases: {
            username: true,
            email: true
        }
    });

    new CfnOutput(this, 'UserPoolId', {
        value: this.userPool.userPoolId
    })
}
```
* Creates a new User Pool named UserPool, with user sign-up enabled with only username and email address.
* `CfnOutput` provides output to console during CDK Deploy, whereby the UserPoolID is displayed.

##### Create User Pool Client
``` typescript
private createUserPoolClient(){
    this.userPoolClient = this.userPool.addClient('UserPoolClient', {
        authFlows: {
            adminUserPassword: true,
            custom: true,
            userPassword: true,
            userSrp: true
        }
    })

    new CfnOutput(this, 'UserPoolClientId', {
        value: this.userPoolClient.userPoolClientId
    })
}
```
* Creates a new User Pool Client, which are specified under the App Integration tab of the User Pool, providing the app client name, authentication flow, session duration, and hosted UI settings.
* Here we name the client UserPoolClient and attach it to the User Pool.
* `CfnOutput` will output to console, the User Pool Client ID, during CDK Deploy.

##### Create User Pool Groups
``` typescript
private createUserGroup(){
    const cfnUserPoolGroup = new cognito.CfnUserPoolGroup(this, 'UserPoolGroup', {
        userPoolId: this.userPool.userPoolId
    })
}

private createAdminGroup(){
    new CfnUserPoolGroup(this, 'Admins', {
        userPoolId: this.userPool.userPoolId,
        groupName: 'admins',
        roleArn: this.adminRole.roleArn
    })
}
```
* Creates two user pool groups, attached to the User Pool, UserPoolGroup and Admins. The createAdminGroup function also contains added property values for `groupName`, which will provide a cleaner group name, 'admins', and roleArn, which maps the group to the 'adminRole', created below.

##### Create Identity Pool
``` typescript
private createIdentityPool(){
    this.identityPool = new CfnIdentityPool(this, 'IdentityPool', {
        allowUnauthenticatedIdentities: true,
        cognitoIdentityProviders: [{
            clientId: this.userPoolClient.userPoolClientId,
            providerName: this.userPool.userPoolProviderName
        }]
    })

    new CfnOutput(this, 'IdentityPoolId', {
        value: this.identityPool.ref
    })

    this.identityPool.identityPoolName
}
```
* Created an Identity Pool named IdentityPool, allowing Unauthenticated Users, and specifying Cognito User Pool as the Identity Provider referencing the User Pool Client via `clientId` and User Pool Identity Provider as `providerName`.
* Here, the User Pool Client options and User Pool Identity Provider come together for integration with the Identity Pool.
* `CfnOutput` print to console the Identity Pool ARN.

##### Create IAM Roles
``` typescript
private createRoles(){
    this.authenticatedRole = new Role(this, 'CognitoDefaultAuthenticatedRole', {
        assumedBy: new FederatedPrincipal('cognito-identity.amazonaws.com', {
            StringEquals: {
                'cognito-identity.amazonaws.com:aud': this.identityPool.ref
            },
            'ForAnyValue:StringLike': {
                'cognito-identity.amazonaws.com:amr': 'authenticated'
            }
        },
        'sts:AssumeRoleWithWebIdentity'       
        )
    })

    this.unauthenticatedRole = new Role(this, 'CognitoDefaultUnauthenticatedRole', {
        assumedBy: new FederatedPrincipal('cognito-identity.amazonaws.com', {
            StringEquals: {
                'cognito-identity.amazonaws.com:aud': this.identityPool.ref
            },
            'ForAnyValue:StringLike': {
                'cognito-identity.amazonaws.com:amr': 'unauthenticated'
            }
        },
        'sts:AssumeRoleWithWebIdentity'       
        )
    })

    this.adminRole = new Role(this, 'CognitoAdminRole', {
        assumedBy: new FederatedPrincipal('cognito-identity.amazonaws.com', {
            StringEquals: {
                'cognito-identity.amazonaws.com:aud': this.identityPool.ref
            },
            'ForAnyValue:StringLike': {
                'cognito-identity.amazonaws.com:amr': 'authenticated'
            }
        },
        'sts:AssumeRoleWithWebIdentity'       
        )
    })

    this.adminRole.addToPolicy(new PolicyStatement({
        effect: Effect.ALLOW,
        actions: ["s3:ListAllMyBuckets"],
        resources: ['*']
    }))

    new CfnOutput(this, 'AdminRoleArn', {
        value: this.adminRole.roleArn
    })
}
```
* Creates three IAM Roles, CognitoDefaultAuthenticatedRole, CognitoDefaultUnauthenticatedRole, and CognitoAdminRole, with the last containing a `PolicyStatement` via the `addToPolicy` method, to allow the listing of all S3 Buckets within the AWS Account.
* All three roles make user of the `assumedBy` property, by creating a new `FederatedPrincipal` object, each role contains a JSON object of 'Trusted entities', allowing each role to be assumed by the Identity Pool created above.
  * CognitoDefaultAuthenticatedRole performs a `StringEquals` for Cognito Authenticated Users, allowing only users Authenticated by Cognito to assume this role, with the following line under `ForAnyValue:StringLike`: `'cognito-identity.amazonaws.com:amr': 'authenticated'`.
    * Authenticated User will inherit the policy associated with this role. Currently, no policy statement has been set.
  * CognitoDefaultUnauthenticatedRole is the same as the role above, however, `ForAnyValue:StringLike`: `'cognito-identity.amazonaws.com:amr': 'unauthenticated'` for assumption of the role by unauthenticated users.
  * CognitoAdminRole contains the same JSON as CognitoDefaultAuthenticatedRole, for use by Admin users. This role will only work for Authenticated Users, but contain the permissions as listed within the `addToPolicy` method.
    * In addition to the AWS permissions provided by the policy statement, API Gateway will receive the Access Token supplid by the Authorization header. Downstream, a Lambda function may parse the event claims' `'cognito:groups:'` key, and based on it value, allow the coded permissions.
      * For example, a `hasAdminGroup` function may be created, whereby the event body is supplied, and if any values in the list match 'admin', will allow certain API methods. Perhaps only the Delete method would contain the following code:
      * ``` typescript
        if (!hasAdminGroup(event)){
          return {
              statusCode: 401,
              body: JSON.stringify('Not authorized!')
          }
        }
        ```

###### Identity Pool Role Attachments & Mappings
``` typescript
private attachRoles(){
    new CfnIdentityPoolRoleAttachment(this, 'RolesAttachment', {
        identityPoolId: this.identityPool.ref,
        roles: {
            'authenticated': this.authenticatedRole.roleArn,
            'unauthenticated': this.unauthenticatedRole.roleArn
        },
        roleMappings: {
            adminsMapping: {
                type: 'Token',
                ambiguousRoleResolution: 'AuthenticatedRole',
                identityProvider: `${this.userPool.userPoolProviderName}:${this.userPoolClient.userPoolClientId}`
            }
        }
    })
    }
```
* The IAM Roles will be attached to the Identity Pool, whereby the Identity Pool is specified using `this.identityPool.ref`, and the default authenticated and unauthenticated roles via `'authenticated': this.authenticatedRole.roleArn` and `'unauthenticated': this.unauthenticatedRole.roleArn` lines.
* Role mapping are specified within the nested JSON `roleMappings:` object. In the above example, the name is specified as `adminsMapping`, which is of type `Token`, with `ambiguousRoleResolution` set to `AuthenticatedRole`. The `identityProvider` contains the User Pool Provider name from the userPool object, concatenated with a `:` and the User Pool Client ID.
  * Setting Type to 'Token' will use the `cognito:roles` and `cognito:preferred_role` from the ID Token claims supplied by the Cognito Identity Provider. The IAM roles are mapped via the user group memberships within the Cognito Identity Provider, as listed within the `'cognito:groups:'` claim.
  * Setting Type to 'Rules' will attempt to match claims from the ID Token to map a role. In this case the `roleMappings` JSON would be as follows:
      ```
      roleMappings: {
          adminsMapping: {
              type: 'Rules',
              ambiguousRoleResolution: 'AuthenticatedRole',
              identityProvider: `${this.userPool.userPoolProviderName}:${this.userPoolClient.userPoolClientId}`,
              rulesConfiguration: {
                rules: [{
                  claim: 'claim',
                  matchType: 'matchType',
                  roleArn: 'roleArn',
                  value: 'value',
                }]
              }
          }
      }
      ```
  * In addition, the IAM policy attached to the Authenticated role will also be applied but not listed within any of the claims, granted permissions as provided across all mapped roles and the authenticated roles.
  * Unauthenticated users will receive permissions against the Unauthenticated Role. APIs may still choose to allow access to certain to methods omitting a check against the Access Token.

###### Disparate App Client API Method Access
*Authorization Scopes* are used to determine the granted permissions for an app. Authorization Scopes are supplied to each API Method, by providing the Authorization value as the Cognito User Pool. A domain for the user pool must be configured, at which point, Amazon Cognito automatically provisions an OAuth 2.0 authorization server and hosted web UI with sign-up and sign-in pages that the web app can present to users. Authentication to the sign-in pages creates and ID Token and Access Token, which  then may be used to access the API resource.

* A Resource Server is an OAuth 2.0 API server, such as the API Gateway and its methods pointing to a Lambda function handler. It validates that access tokens from the user pool contain the scopes that authorize the requested method and path in the API that protects it.
* Access tokens are the OAuth 2.0 JWT tokens which contain claims, including custom claims, recall from the [Breaking Down The CDK Constructs](#breaking-down-the-cdk-constructs) section above. You also learned that 'aws.cognito.signin.user.admin' was added by default to the claims within the Access token. It authorizes the bearer of an access token to query and update all information about a user pool user with, for example, the GetUser and UpdateUserAttributes API operations.
  * GetUser: Gets the user attributes and metadata for a user. More details within the API Reference for [Amazon Cognito User Pools](https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_GetUser.html).
  * UpdateUserAttributes: Allows users to update one or more of their attributes with their own credentials. More details within the API Reference for [Amazon Cognito User Pools](https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_UpdateUserAttributes.html).
* Additional *Custom Scope* are required in order to parse them from the API Authorizer to grant each method's API access.
  * For example, 'read' would be parsed by the `GET` resource to allow access to this API method.
  * Custom scopes are added to the Cognito User Pool, App Integration, Resource servers, within the AWS Management Console.
  * The created custom scopes are then added within the Identity Pool associated with the User Pool.

* [Read more about Cognito Custom Scopes for API Gateway](https://repost.aws/knowledge-center/cognito-custom-scopes-api-gateway)
* [Read more details about OAuth 2.0 scopes and API Authorization with resource server](https://repost.aws/knowledge-center/cognito-custom-scopes-api-gateway)

###### Adding a Resource Server
``` typescript
private createResourceServers(){
    const readOnlyScope = new cognito.ResourceServerScope({ scopeName: 'read', scopeDescription: 'Read-only access' });
    const fullAccessScope = new cognito.ResourceServerScope({ scopeName: '*', scopeDescription: 'Full access' });

    const userServer = this.userPool.addResourceServer('ResourceServer', {
        identifier: 'users',
        scopes: [ readOnlyScope, fullAccessScope ],
      });
      
      const readOnlyClient = this.userPool.addClient('read-only-client', {
        // ...
        oAuth: {
          // ...
          scopes: [ cognito.OAuthScope.resourceServer(userServer, readOnlyScope) ],
        },
      });
      
      const fullAccessClient = this.userPool.addClient('full-access-client', {
        // ...
        oAuth: {
          // ...
          scopes: [ cognito.OAuthScope.resourceServer(userServer, fullAccessScope) ],
        },
      });
}
```
* Created two different resource servers named 'read-only-client' and 'full-access-client'. The resource servers create two different access scopes, `scopeName: 'read', scopeDescription: 'Read-only access'` and `scopeName: '*', scopeDescription: 'Full access'`, added to their respective resource servers. Each resource servers is accessed by its client ID, generated upon creation. The resource servers are then accessed by the hosted UI and client ID. In response will be either an ID and Access Token or Authorization Code, depending on the Authorization Flow. Authorization Codes are then redeemed for ID & Access Tokens, using the [Token Endpoint](https://docs.aws.amazon.com/cognito/latest/developerguide/token-endpoint.html).

The following is an example CURL request/response to/from the token endpoint for the Authorization Code flow using an Access Code. This is for illustrative purposes and would not work for a single page app written in React.

Request
```
curl --location --request POST 'https://example-est.auth.us-east-1.amazoncognito.com/oauth2/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'client_id=5j9701eo7qmhf91oth5eks6kii' \
--data-urlencode 'code=79927d32-ba18-4cff-8254-b7d43d1347a2' \
--data-urlencode 'grant_type=authorization_code' \
--data-urlencode 'redirect_uri=https://example.com'
```

Response
``` json
{"id_token":"eyJraWQiOiI3SFRmUHF3OTdVRHQwdTQ0cFoyVVZQMFVCVUV5d0toWlNmYVNsc0pTdWl3PSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoibzBNVDBnWVEwbVdua3EwdnA2dHk4ZyIsInN1YiI6ImQ0ODhlNDM4LWIwZDEtNzAxMS1iYzJjLTYwNGExOTlmY2RkNSIsImNvZ25pdG86Z3JvdXBzIjpbImFkbWlucyJdLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tXC91cy1lYXN0LTFfOGo2UjZqS0NZIiwiY29nbml0bzp1c2VybmFtZSI6ImFsZWNobm9zIiwib3JpZ2luX2p0aSI6IjYyMGEwMTY2LTRhNGItNDA0Ny1iNGQzLWFmN2U5MWE1NTQ0NyIsImNvZ25pdG86cm9sZXMiOlsiYXJuOmF3czppYW06OjgyMDEyNzUwOTgxMjpyb2xlXC9BdXRoU3RhY2stQ29nbml0b0FkbWluUm9sZTRDMTBGQkE0LUVpRFRIb0VmMWFuUiJdLCJhdWQiOiI1ajk3MDFlbzdxbWhmOTFvdGg1ZWtzNmtpaSIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNzA4NjMxOTg0LCJleHAiOjE3MDg2MzU1ODQsImlhdCI6MTcwODYzMTk4NSwianRpIjoiYzJmMzMwZWQtYmE0Zi00YzNmLWJhY2ItMDQyNDA3ZGE2NTZmIiwiZW1haWwiOiJhZGFtLmxlY2hub3NAZ21haWwuY29tIn0.veWBGSGEUL8Gz9zHLHa0oWm6L_w3Y76-GtXG_oYnDrmgVAHU7e2RYCE7YEYRN2Mh1sZVLEXZdbQIgO-BNjQqbfLQwIeyDz4o0hAakUMYwuBvk1f9WfntTuszCS8jCZvK2ERZ8r9utcpKndjqVWt2RzGmYaSgJXa5xdCZXfSS77y3KhRvLKY-4AI-pnuthheRHFUzxZHkDhM0YXjL3lKSpjI3697bDBa5K-qRMTVNO37uVAno_AUJ1bb0C7iqwWAC0DN9D6QyGetY0coh4ex9IxmoHiti7D9pZKAyriufa5P6VAk-QNJpPWJ1b0rkT4dIZ_4vG2Ydh63hvUPN99NO_g","access_token":"eyJraWQiOiIyRDRPSlk2ZTY4OGt0aU94eXBSNWRvWEtEc3lHYmFCR01WWmJmYm1oN0dvPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJkNDg4ZTQzOC1iMGQxLTcwMTEtYmMyYy02MDRhMTk5ZmNkZDUiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbnMiXSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tXC91cy1lYXN0LTFfOGo2UjZqS0NZIiwidmVyc2lvbiI6MiwiY2xpZW50X2lkIjoiNWo5NzAxZW83cW1oZjkxb3RoNWVrczZraWkiLCJvcmlnaW5fanRpIjoiNjIwYTAxNjYtNGE0Yi00MDQ3LWI0ZDMtYWY3ZTkxYTU1NDQ3IiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJhd3MuY29nbml0by5zaWduaW4udXNlci5hZG1pbiBvcGVuaWQgdXNlcnNcL3JlYWQiLCJhdXRoX3RpbWUiOjE3MDg2MzE5ODQsImV4cCI6MTcwODYzNTU4NCwiaWF0IjoxNzA4NjMxOTg1LCJqdGkiOiI1YjI1YTRhYS0zZGZjLTRiZWUtOGIyMS0zMjA4NTRlY2QyOGUiLCJ1c2VybmFtZSI6ImFsZWNobm9zIn0.EWCEwDk46i8fOU4IVnlwgM7XNz_i-jtYcpyOYE8q4YGFC7giK5lWgzgIcD9_zHzUF6bVc6iv1uqtQDEXZlOU7pofMhUWBykqnDUC0Q57X4bP3giDigIYmfj77zJLxlWhwRvim28hZfJg9Sz_RIBcf13lo4D8bZvTE5HVEEI-tztuA4B-1dDY65po2zMHqwBEWF9FYaQC2edm5lyQEtTFleHVawBVbQWIU3Ud16TznAy9WEp2q_QgsNSFKuF-2LnQuO27MfyFWFGza8gDMrBwxVJ1l9bjrJuLH300QqQWLdaX7FTupOZHtvUxeND3K4Hc0-ZTu-nvpGUYOAxemfyyIQ","refresh_token":"eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.RMAy1jPNXxpGdPIr1TUukG685KbV5JgokWkBtnWDFOOlcFSRGWS-uNkglPdJJv4g1r4nk7jxYY8J8HnYmomzlt7OD0FdSnvrCEr61SbDZz5FZ9jhzdl-p2_fEoi_fUydpwG_JUliFucvutwDcBd1W2Ul900b24m1nHSrq_NL8r9uFJcVrkFDWLKQ9fxipSYZyU37LePN-qrxX78pQS2vIIe8tVvrG6CuK4GjdRDUvz10tpDFHdTFH75Bn0GHr5xoXXCuTg7CkuyipVYapYeI_AwJIEYBfLzlUjl99hrfkxDUVqlpyqgj9Jq_NOsXwt-sd73ZbPoBGAurAIw2Yw6mxg.WUaX_U7nlacSnml-.CctUJfNf4hngQr4QktmuTWTT5myYN03GzwVWgktiQpGHccW5jgK9QSQmKIG5v33qHoG5KOpm7xyKU9YsehJjpZHj8yq_NMMEamk7DCv4UR7ooXBJS2Hf6KL7Y-2sFxD6Eec7P37t1HtP5QOB1P5CNZgxW069hQpKj6uyOmOqvrso88Jtk18HjRw0SZY1r2jzdey-PRsoinukv2_JWaH2A35QFuApVwurov3DWl7kNKXkQldOROkYC1xrOidXxVTfirschCxSTcNWf481Jh9BF-W_eYcnyAJU0RAFQjZdLEdEUBTl2uH3jTVfGl9qdq32oXmd_EoeugBCW2zUbgekJbRlfmMWt42bZ67qz6ZAZ-cgijp16g1f01pXKV-vKdXIvjOm6IZin9whMwoK4i6zFjfAZLlYPRP2N-lZCRW8d7YeOz7S00OISy5qHF6DpDhm6sWFe0VBmyaYjZKzZob99DXyXBVLJukn1_R2MD5nJNRzCUvJCni3RZ4vEOW8lUK2RwcGjPiLgMH9EalVcALsIq0zV_SsSHUzgXeuvFz6sP-ygIkogrfLKGnGg5ssMpsL6rAlmSskz39veMmWDRxzx20daQXr_vpRHVmk5_Lg6alX7l3uMNGUOpvLEJssRsDWf99kuyXYWA0aqNr80RiJS67TXX0DrmhKtipvnd_cb3G5xcvVsu5xc37g9UnA57Bzvi1ulB9XlcgfrpKZxgPUTV0OtWvVvUDIoi06aOCOMeQgcMBRKoS6T8Qrplg8OzCGmg5cNPgap8foPfD9qgY5DWDlMgtmtohmH_Sg8dFTAdE0fmWhFXmWw5ErVlg4Ea0FtOl5ix8DqOQx0hT_ClhGW-aiXUHoVy7uZHK2Fa385aBoxrk-DtxO5r0ROUjnVwGTVUdUPBFWAb905nTs1K5cvWgkwdRp-wq4NFhwcDy8T1h5Dss3kouIx53JiZv5E4gsroynF7fOL_4vxlt0dM-ykWBB1sN988cTvqUNunWM3vofNWnaEg-_YP7xbOFas78HKqqm4-2UNlM0bYY8E8D6TDf9KtPbZb0Pt2HuJYv6z9JiAmS24Og7Bce1DiEOlGafLrSMgkHp84TumRXWOLurJtVIW2MajM06k3xvAQYdP4rcb4zgss_Pegtq-6AWgNpJ7TvT14NLjm2GXahu2x6gr4EG8Tr3LRDJwOAkxxNwogv2RfBqI8YrjQzDZ_-jzwhhdOvvik3FswYoeLv-UGy333K4gYYEu9SuPsvV5ag.Uy9EJjNpUCosi7jYTiIdew","expires_in":3600,"token_type":"Bearer"}
```

JWT.io deencoded Access Token
``` json
{
  "sub": "d488e438-b0d1-7011-bc2c-604a199fcdd5",
  "cognito:groups": [
    "admins"
  ],
  "iss": "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_8j6R6jKCY",
  "version": 2,
  "client_id": "5j9701eo7qmhf91oth5eks6kii",
  "origin_jti": "620a0166-4a4b-4047-b4d3-af7e91a55447",
  "token_use": "access",
  "scope": "aws.cognito.signin.user.admin openid users/read",
  "auth_time": 1708631984,
  "exp": 1708635584,
  "iat": 1708631985,
  "jti": "5b25a4aa-3dfc-4bee-8b21-320854ecd28e",
  "username": "username"
}
```
* The de-encoded Base64 Access Token indicates the scope values which were also attached to the resource server, `"scope": "aws.cognito.signin.user.admin openid users/read"`.

The next post will go-over testing the CDK's Authorization Stack, by writing some test code in TypeScript.

<sub>*[Original code snippets by Alex Dan via Udemy](https://www.udemy.com/course/aws-typescript-cdk-serverless-react/?couponCode=ST15MT31224#instructor-1)*<sub>
