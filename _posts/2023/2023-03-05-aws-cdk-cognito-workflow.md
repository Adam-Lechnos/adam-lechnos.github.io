---
title: "AWS CDK - Breaking Down AWS Cognito OAuth & OIDC Workflows"
date: 2023-03-05 12:00:00 -0000
categories: aws devops cdk typescript
---

### Diagram

#### [Amazon Cognito OAuth & OIDC Workflow (draw.io viewer)](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=OAuth20-Sequence-Diagram.drawio#Uhttps%3A%2F%2Fraw.githubusercontent.com%2FAdam-Lechnos%2Fdiagrams-charts%2Fmain%2Fdevops%2FOAuth20-Sequence-Diagram.drawio){:target="_blank" rel="noopener"}

![Amazon Cognito OAuth & OIDC Workflow]({{ site.github-content }}/devops/OAuth20-Sequence-Diagram.drawio.svg?raw=true)

In my previous blog post, ["AWS CDK - Using Amazon Cognito Authentication and Authorization"](/aws/devops/cdk/typescript/2023/02/22/aws-cdk-cognito-use.html){:target="_blank" rel="noopener"}, I go-over implementing Cognito Authentication & Authorization workflow into your application via the AWS CDK. I attempt here, to dive deeper into the workflow components as they relate to AWS Cognito in alignment with OAuth standards. For more context, reading the previous post or series of posts within the subject matter will shed more light into this deep-dive.

#### AWS Cognito with CDK Post Series
1. [AWS CDK - Understanding Amazon Cognito Authentication and Authorization](https://www.adamlechnos.com/aws/devops/cdk/typescript/2023/02/20/aws-cdk-cognito.html)
1. [AWS CDK - Testing Amazon Cognito Authentication and Authorization](https://www.adamlechnos.com/aws/devops/cdk/typescript/2023/02/21/aws-cdk-cognito-testing.html)
1. [AWS CDK - Using Amazon Cognito Authentication and Authorization](https://www.adamlechnos.com/aws/devops/cdk/typescript/2023/02/22/aws-cdk-cognito-use.html)

### Breaking It Down

#### Components (from left to right)

* Web Application - from the previous example was a React App hosted within an S3 bucket
* Resource Server - Each Resource Server may contain a list of defined Custom Scopes. Authorization with an Access Code must be returned to the [Token Endpoint](https://docs.aws.amazon.com/cognito/latest/developerguide/token-endpoint.html) when using Authorization Code Grant to receive the Custom Scopes. Custom Scopes get injected into the Access Token based on the associated App Client. Multiple Resource Servers may defined.
* Authorization Server - Cognito User Pool, where users, User Groups, User Groups default roles, App Clients, and Resource Servers are defined. Federated Identity may also be configured here.
  * App Client - Custom Scopes are attached from the Resource Server to each App Client. Multiple App Clients may be defined each with their own set of Resource Server created Custom Scopes.
  * Federated Identity Providers (IdP) may be OAuth, OIDC, SAML, and other popular social and cloud integrations such as 'Sign-in with Amazon', 'Sign-in with Google' and Facebook.
* AWS Credentials - Cognito Identity Pool which gets associated with an App Client. The Identity Pool associated with the App Client gets used. Role mappings are defined based on either the Rules or Token method. Refer to the [previous post](/aws/devops/cdk/typescript/2023/02/22/aws-cdk-cognito-use.html) for more details. Default IAM Roles are configured for Authenticated and Unauthenticated (Guest) access, providing a baseline set of roles the Web App may use. Role mapping may either be used with or overwrite the default IAM role base on the Role Mapping Rule utilized.
* API Gateway - A Cognito Authorizer may be defined for the API, which then gets utilized be each API method. The API methods may specify Custom Scopes to ensure more fined-grained permissions. The API method can check for these custom scopes before access to the API is granted. Custom Scopes are defined in the Resource Server and attached to the App Client within an Identity Pool before they get injected into the the Access Token for authorization. The Base64 encoded JWT token must be specified.

#### The Flow

1. Authenticate - Based on how the associated Identity Pool is configured, upon successful Authentication to the Hosted UI, the following gets generated:
   1. Access Token (JWT format), ID Token (JWT format according to Open ID Connect), and AWS Credentials.
1. OAuth flow - Based on how the Authentication flow is configured within the App Client, upon successful authentication in step 1, the following flow occurs:
    1. Implicit Grant - Requests and Returns an Access Token to the Web App via the browser (or user agent which is not depicted in the diagram)
    1. Authorization Grant - Requests an Authorization Code to the App Clients token endpoint and returns an Access Code. Use the Access Code to request an Access Token. Custom Scopes are injected into the Access Token via the Resource Server. This exchange occurs outside of the browser on the server side whereby the server side performs the subsequent requests to the Resource Server.
        1. This flow will not work with single page applications such as those written in React where no server side channel exist.
1. The multiple grants returned to the client as follows:
    1. Access Token in JWT format - Used for accessing API resources defined within the API Gateway.
    1. ID Token in JWT format - Open ID Connect JWT containing the Cognito Roles and Groups, which enable IAM assumed roles to the listed role ARNs, and [standard claims](https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims) such as 'sub' and 'name'. The details provided enable personalized user experience within the web application. More details about ID TOkens from a prior [blog post](/aws/devops/cdk/typescript/2023/02/20/aws-cdk-cognito.html#id-tokens)
    1. AWS Credentials - Contains an AWS Access Key, Secret Access Key, and Session Token, for use by the Web Application for access to various AWS resources. For example, permissions to an S3 bucket for uploading an image which can than be returned as a profile photo. The assumed role as contingent upon the Identity Pool's default assigned role and/or Role Mappings which then dictate the `cognito:preferred_role` value within the token. Refer to [Assigning precedence values to groups](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-user-groups.html#assigning-precedence-values-to-groups) for more details.

#### Breaking Down OAuth Scopes A Bit Further
I wanted to add some additional context that may have been lacking in previous blog posts regarding scopes. Here is how I break down with references to additional reading:

* A great example of custom scopes may be explored via [Google's OAuth 2.0 Playground](https://developers.google.com/oauthplayground/). Using these third party defined scopes is what enables access permissions to those APIs, such as the aforementioned Google APIs.
* Standard scopes will also get injected. Cognito based User Pools inject the `aws.cognito.signin.user.admin` scope, which enables Cognito Users access read and write their attributes. Other standard scopes include:
  * openid - The minimum scope for OpenID Connect queries which authorizes the ID token the unique-identifier `sub`, and the ability to request other scopes
  * profile - Authorizes all user attributes that the app client can read
  * email - Authorizes the user attributes `email` and `email_verified` with `email_verified` sent back from Cognito if the value is explicitly set.
  * phone - Authorizes the user attributes `phone_number` and `phone_number_verified`.
  * Refer to the [Developer Guide](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-define-resource-servers.html#cognito-user-pools-define-resource-servers-about-scopes) for Amazon Cognito Scopes for more details.

##### Example OAuth Access Token
``` json
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
```

#### Breaking Down OpenID Connect A Bit Further
I also wanted to add a bit more clarification regarding OpenID Connect (OIDC) ID Tokens. OpenID Connect will use the same Authorization Server as OAuth, however, for OpenID Connect, the Authorization Server will return information regarding the authenticating user. In case if you have not figured out the difference between OpenID Connect and OAuth, OpenID Connect is an Authentication protocol as opposed to OAuth being an Authorization protocol. OpenID Connect is more interested in solving Authentication and the mechanism by which we acquire details specific to the end-user, such as profile related email, name, phone number, etc.

* OpenID Connect makes use of [UserInfo endpoint](https://docs.aws.amazon.com/cognito/latest/developerguide/userinfo-endpoint.html). When you specify the `profile` and `openid` scopes in OAuth, you are granting the bearer permissions to use the profile and other related OpenID connect information against this endpoint.
* Typically, the app makes a call from the back channel and not the browser. For single page application written in client side code such as React, this will however occur between the client and Authorization server.
  * For Cognito, the UserInfo endpoint is `/oauth2/userInfo`.
  * Amazon Cognito returns the `email_verified` and `phone_number_verified` claims within the ID Token.
  * Recall, the standard claims that are issued by OpenID Connect are presented within the [official spec](https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims).
    * Some of these claims are: `sub`, `name`, `given_name`, and `family_name`.
  * Also recall, we were scoped by the OAuth Access token which granted the application access to these claims. Cognito User Pool users only require the  `aws.cognito.signin.user.admin` scope.
  * The user attributed are presented by the userInfo endpoint when presented with an OAuth Access Token. The Open ID Connect Token responds with user attributed based on the scopes of the OAuth token.
  * The OAuth third-party identity provider (IdP) also hosts a userInfo endpoint. When the user authenticated with that IdP, Cognito will exchange an authorization code with the IdP token endpoint. The user pool then passes the IdP access token to the userInfo endpoint for authorized retrieval of the user attributes from that IdP.
  * Read more details about the UserInfo endpoint from the [Developer Guide](https://docs.aws.amazon.com/cognito/latest/developerguide/userinfo-endpoint.html) for Cognito.

##### Example OIDC ID Token
``` json
{
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
```