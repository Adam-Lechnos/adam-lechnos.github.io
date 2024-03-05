---
title: "AWS CDK - Breaking Down AWS Cognito OAuth & OIDC Workflow"
date: 2023-03-05 12:00:00 -0000
categories: aws devops cdk typescript
---

### Diagram

#### [Amazon Cognito OAuth & OIDC Workflow (draw.io viewer)](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=OAuth20-Sequence-Diagram.drawio#Uhttps%3A%2F%2Fraw.githubusercontent.com%2FAdam-Lechnos%2Fdiagrams-charts%2Fmain%2Fdevops%2FOAuth20-Sequence-Diagram.drawio){:target="_blank" rel="noopener"}

![Amazon Cognito OAuth & OIDC Workflow]({{ site.github-content }}/devops/OAuth20-Sequence-Diagram.drawio.svg?raw=true)

In my previous blog post, ["AWS CDK - Using Amazon Cognito Authentication and Authorization"](/aws/devops/cdk/typescript/2023/02/22/aws-cdk-cognito-use.html){:target="_blank" rel="noopener"}, I go-over implementing Cognito Authentication & Authorization workflow into your application via the AWS CDK.

### Breaking It Down

#### Components (from left to right)

* Web Application - from the previous example was a React App hosted within an S3 bucket
* Resource Server - Each Resource Server may contain a list of defined Custom Scopes. Authorization with an Access Code must be returned to the [Token Endpoint](https://docs.aws.amazon.com/cognito/latest/developerguide/token-endpoint.html) when using Authorization Code Grant to receive the Custom Scopes. Custom Scopes get injected into the Access Token based on the associated App Client. Multiple Resource Servers may defined.
* Authorization Server - Cognito User Pool, where users, User Groups, User Groups default roles, App Clients, and Resouce Servers are defined. Federated Identity may also be configured here.
  * App Client - Custom Scopes are attached from the Resource Server to each App Client. Multiple App Clients may be defined each with their own set of Resource Server created Custom Scopes.
  * Federated Identity Providers (IdP) may be OAuth, OIDC, SAML, and other popular social and cloud intergrations such as 'Sign-in with Amazon', 'Sign-in with Google' and Facebook.
* AWS Credentials - Cognito Identity Pool which gets associated with an App Client. The Identity Pool associated with the App Client gets used. Role mappings are defined based on either the Rules or Token method. Refer to the [previous post](/aws/devops/cdk/typescript/2023/02/22/aws-cdk-cognito-use.html) for more details. Default IAM Roles are configured for Authenticated and Unauthenticated (Guest) access, providing a baseline set of roles the Web App may use. Role mapping may either be used with or overwrite the default IAM role base on the Role Mapping Rule utilized.
* API Gateway - A Cognito Authorizer may be defined for the API, which then gets utilzed be each API method. The API methods may specify Custom Scopes to ensure more fined-grained permissions. The API method can check for these custom scopes before access to the API is granted. Custom Scopes are defined in the Resource Server and attached to the App Client within an Identity Pool before they get injected into the the Access Token for authorization. The Base64 encoded JWT token must be specified.

#### The Flow

1. Authenticate - Based on how the associated Identity Pool is configured, upon successful Authentication to the Hosted UI, the following gets generated:
  1. Access Token (JWT format), ID Token (JWT format according to Open ID Connect), and AWS Credentials.
1. OAuth flow - Based on how the Authentication flow is configured within the App Client, upon successful authentication in step 1, the following flow occurs:
  1. Implicit Grant - Requests and Returns an Access Token to the Web App
  1. Authorization Grant - Requests an Authorization Code to the App Clients token endpoint and return an Access Code. Use the Access Code to request an Access Token. Custom Scopes are injected into the Access Token via the Resource Server. This exchange occurs outside of the browser on the server side. The client only received the final Access Token.
1. The multiple grants returned to the client as follows:
  1. Access Token in JWT format - Used for accessing API resources defined within the API Gateway.
  1. ID Token in JWT format - Open ID Connect JWT containing the Cognito Roles and Groups, which enable IAM assumed roles to the listed role ARNs, and [standard claims](https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims) such as 'sub' and 'name'. The details provided enable personalized user experience within the web application. More details about ID TOkens from a prior [blog post](/aws/devops/cdk/typescript/2023/02/20/aws-cdk-cognito.html#id-tokens)
  1. AWS Credentails - Contains an AWS Access Key, Secret Access Key, and Session Token, for use by the Web Application for access to various AWS resources. For example, permissions to an S3 bucket for uploading an image which can than be returned as a profile photo. The assumed role as contingent upon the Identity Pool's default assigned role and/or Role Mappings which then dictate the `cognito:preferred_role` value within the token. Refer to [Assigning precedence values to groups](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-user-groups.html#assigning-precedence-values-to-groups) for more details.