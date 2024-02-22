---
title: "AWS CDK - Testing Amazon Cognito Authentication and Authorization"
date: 2023-02-21 12:00:00 -0000
categories: aws devops cdk typescript
---

### Diagram

#### [Amazon Cognito Client Workflow (draw.io viewer)](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=Devops-IaC-AWS_CDK_Cognito.drawio#Uhttps%3A%2F%2Fraw.githubusercontent.com%2FAdam-Lechnos%2Fdiagrams-charts%2Fmain%2Fdevops%2FDevops-IaC-AWS_CDK_Cognito.drawio){:target="_blank" rel="noopener"}

![Amazon Cognito Client Workflow]({{ site.github-content }}/devops/Devops-IaC-AWS_CDK_Cognito.drawio.svg?raw=true)

In my previous blog post, ["AWS CDK - Understanding Amazon Cognito Authentication and Authorization"](aws-cdk-cognito.html){:target="_blank" rel="noopener"}, I go-over creating an Auth Stack, whereby a web service may provide protected access to APIs and AWS resources, depending on client authentication and access scopes. This article will delve into testing the Auth Stack, using TypeScript calls to the built-in CDK modules and contructs.

### Creating an AuthService Test 

#### AuthService.ts exported functions

Refer to the full example [GitHub Gist](https://gist.github.com/Adam-Lechnos/ffdf98d046af91d1c6fe2138ce94017b)

```
Amplify.configure({
    Auth:{
        Cognito: {
            userPoolId: 'us-east-1_8j6R6jKCY',
            userPoolClientId: '66h766je9tqbba2fbip9j60hqb',
            identityPoolId: 'us-east-1:3ae853a4-e0a7-4b8f-a6d2-263b1e2da9f2'
        }
    }
})
```
* Using AWS Amplify module, configure Cognito User Pool, User Pool Client, and User Pool ID.

```
export class AuthService {
    public async login(username: string, password: string){
        const result = (await signIn( {username, password, options: {authFlowType: 'USER_PASSWORD_AUTH'}})) 
          as SignInOutput
        return result
    }
}
```
* Create the login method against the exported `AuthService`, taking in two argument, Cognito Username and Password. The return result will be the username and password applied to the `signIn` of the Amplify module, with `{authFlowType: 'USER_PASSWORD_AUTH'}` set as the sign-in options.

##### Analyzing the 'signIn' TypeScript type is as follows:

```
export declare function signIn(input: SignInInput): Promise<SignInOutput>;

export type SignInInput = AuthSignInInput<SignInOptions>;

export type AuthSignInInput<ServiceOptions extends AuthServiceOptions = AuthServiceOptions> = {
    username: string;
    password?: string;
    options?: ServiceOptions;
};

export type SignInOptions = AuthServiceOptions & {
    authFlowType?: AuthFlowType;
    clientMetadata?: ClientMetadata;
};

export type AuthFlowType = 'USER_SRP_AUTH' | 'CUSTOM_WITH_SRP' | 'CUSTOM_WITHOUT_SRP' | 'USER_PASSWORD_AUTH';
```
* The method takes a `AuthSignInInput` type, with `options?` value taking a `ServiceOption` type. The `ServiceOption` type extends `AuthServiceOptions`.
* `AuthServiceOptions` Type presents the following valid options for 'signIn' when used with the `signInOptions` type: `'USER_SRP_AUTH' | 'CUSTOM_WITH_SRP' | 'CUSTOM_WITHOUT_SRP' | 'USER_PASSWORD_AUTH'`.
* For this test, we are using a 'USER_PASSWORD_AUTH'.

#### auth.test.ts call to the exported AuthService.ts functions.

Refer to the full example [GitHub Gist](https://gist.github.com/Adam-Lechnos/9a5154ca155b473af230adfd114fe41e)

```
async function testAuth() {
    const service = new AuthService();
    await service.login('user-bob', 'bobs-password');

    const {idToken} = (await fetchAuthSession()).tokens ?? {}
    const {accessToken} = (await fetchAuthSession()).tokens ?? {}
    const creds = (await fetchAuthSession()).credentials

    console.log(idToken);
    console.log("--------SEPARATOR--------")
    console.log(accessToken)

    await listBuckets(creds)

}
```
* The previously created `AuthService()` object is instantiated and assigned to the `service` variable. The `login` function assigned to 'AuthService' is supplied with the Cognito Username and Password arguments, prepended with `await`, since 'login' returns a [Promise](https://www.codecademy.com/resources/docs/typescript/promises) via `SignInOutPut`.
  * Recall this from the 'signIn' function, `export declare function signIn(input: SignInInput): Promise<SignInOutput>`. When we created the 'AuthService' class, we assigned it to 'async', meaning, we are leveraging the use of Async/Await in TypeScript for the Promise returned.
* We then parse out the `idToken`, `accessToken`, and `creds`, printing all three to the console. These values are taken from the returned `fetchAuthSession` Promise, which is also apart of the Amplify module.

##### Analyzing 'fetchAuthSession' a bit further

```
export declare const fetchAuthSession: (options?: FetchAuthSessionOptions) => Promise<AuthSession>;

export type AuthSession = {
    tokens?: AuthTokens;
    credentials?: AWSCredentials;
    identityId?: string;
    userSub?: string;
};

export type AuthTokens = {
    idToken?: JWT;
    accessToken: JWT;
};

export type AWSCredentials = {
    accessKeyId: string;
    secretAccessKey: string;
    sessionToken?: string;
    expiration?: Date;
};

export type JWT = {
    payload: JwtPayload;
    toString: () => string;
};

interface JwtPayloadStandardFields {
    exp?: number;
    iss?: string;
    aud?: string | string[];
    nbf?: number;
    iat?: number;
    scope?: string;
    jti?: string;
    sub?: string;
}
```
* We can see, `AuthSession` is a Promise, hence, also called with Async/Await. The returned type supplies us with `tokens?`, `credentials?`, etc., each with their own declared type. Hence, we are able to return `tokens` and `credentials` from 'fecthAuthSession'.
* Diving a bit deeper, the return types of 'tokens' is `AuthTokens`, which contain both `idToken` and `accessToken`, each of which are returned as `JWT` types, since both types are formatted as JWT (JSON Web Tokens).
* 'credentials' returns `AWSCredentials` type, which contains `accessKeyId`, `secretAccessKey`, `sessionToken`, and `expiration` strings. 
* Also, the JWT type is provided for analysis here as well, which returns the 'payload' as `JwtPayload`, also shown. 'JwtPayload may be returns as a string using `toString()`'.
* Going yet a bit deeper, 'JwtPayload' returns `JwtPayloadStandardFields` fields, adhering to the JWT standard.

#### Bringing It All Together
Executing the test via the CDK CLI should print to console the ID Token, Access Token, and AWS Credentials.
`ts-node auth.test.ts `

##### Example Output
```
{
  toString: [Function: toString],
  payload: {
    sub: 'd488e438-b0d1-7011-bc2c-604a199fcdd5',
    'cognito:groups': [ 'admins' ],
    email_verified: true,
    iss: 'https://cognito-idp.us-east-1.amazonaws.com/us-east-1_8j6R6jKCY',
    'cognito:username': 'user',
    origin_jti: '79d0f26f-bd39-4dfd6-9f97-0b68c10d5b73',
    'cognito:roles': [
      'arn:aws:iam::820127509812:role/AuthStack-CognitoAdminRole4C10FBA4-EiDTHoEf1anR'
    ],
    aud: '66h766je9tqbba2fbip9j60hqb',
    event_id: '8626e824-ddbb-410a-af39-56ec4c820657',
    token_use: 'id',
    auth_time: 1708633895,
    exp: 1708637495,
    iat: 1708633895,
    jti: 'c9ddfe55-ec2b-4e27-a291-564e52de9aef',
    email: 'user@user.com'
  }
}
--------SEPARATOR--------
{
  toString: [Function: toString],
  payload: {
    sub: 'd488e438-b0d1-7011-bc2c-604a199fcdd5',
    'cognito:groups': [ 'admins' ],
    iss: 'https://cognito-idp.us-east-1.amazonaws.com/us-east-1_8j6R6jKCY',
    client_id: '66h766je9tqbba2fbipdfdfddf0hqb',
    origin_jti: '79d0f26f-bd39-4dfd6-9f97-0b68c10d5b73',
    event_id: '8626e824-ddbb-410a-af39-56ec4c820657',
    token_use: 'access',
    scope: 'aws.cognito.signin.user.admin',
    auth_time: 1708633895,
    exp: 1708637495,
    iat: 1708633895,
    jti: 'c4a365e7-21d9-463d-bfcc-3534866be4c2',
    username: 'user'
  }
}
{
  accessKeyId: 'ASDFRWSDVFU2AZSFREWDS',
  secretAccessKey: 'examplesecretaccesskey',
  sessionToken: 'examplesessiontoken-examplesessiontoken'
}
```
#### Testing The OAuth Token Endpoint for Custom Scopes
When using resource servers for creating auth flows with different scopes, the API Gateway can use these scopes within the Access Token to determine the access granted to the authenticated user.

* Custom scopes added via Resource Servers are then defined within each respective Cognito User Pool Client, each mapping to a Resource Server based on its assigned Custom Scopes.
* Each client provides a separate hosted UI, presented to the end-user for authenticating to the application. Depending on how the auth flow is configured, either an Access and ID token are returned or an Authorization Code which is then exchanged for Access and ID tokens.
  * The former is an Implicit grant, which exposes the tokens within the URL, while the latter uses Authorization code grant flow, which is more secure.

##### Breaking It Down
* Within the AWS Console, click on the appropriate Hosted UI, by first going to the Cognito User Pool, App Integration Tab, then click on the App Client to test under 'App Client and Analytics'.
 * This is where the Auth flows, scopes, callback URLs, and timeout options are assigned.
* Click View Hosted UI, and authenticate. If only a `code=` response is generated within the URL, then an Authorization code grant is being used. Test the returned Authorization Code as follows:

[Example Screenshot]({{ site.github-content-ss }}/devops/Devops-AWS-CDK-Cognito-Test-Screenshot-2023-02-22-175035.png?raw=true)
![Example Screenshot]({{ site.github-content-ss }}/devops/Devops-AWS-CDK-Cognito-Test-Screenshot-2023-02-22-175035.png?raw=true)

The following is an example CURL request/response to/from the token endpoint

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
```
{"id_token":"eyJraWQiOiI3SFRmUHF3OTdVRHQwdTQ0cFoyVVZQMFVCVUV5d0toWlNmYVNsc0pTdWl3PSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoibzBNVDBnWVEwbVdua3EwdnA2dHk4ZyIsInN1YiI6ImQ0ODhlNDM4LWIwZDEtNzAxMS1iYzJjLTYwNGExOTlmY2RkNSIsImNvZ25pdG86Z3JvdXBzIjpbImFkbWlucyJdLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tXC91cy1lYXN0LTFfOGo2UjZqS0NZIiwiY29nbml0bzp1c2VybmFtZSI6ImFsZWNobm9zIiwib3JpZ2luX2p0aSI6IjYyMGEwMTY2LTRhNGItNDA0Ny1iNGQzLWFmN2U5MWE1NTQ0NyIsImNvZ25pdG86cm9sZXMiOlsiYXJuOmF3czppYW06OjgyMDEyNzUwOTgxMjpyb2xlXC9BdXRoU3RhY2stQ29nbml0b0FkbWluUm9sZTRDMTBGQkE0LUVpRFRIb0VmMWFuUiJdLCJhdWQiOiI1ajk3MDFlbzdxbWhmOTFvdGg1ZWtzNmtpaSIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNzA4NjMxOTg0LCJleHAiOjE3MDg2MzU1ODQsImlhdCI6MTcwODYzMTk4NSwianRpIjoiYzJmMzMwZWQtYmE0Zi00YzNmLWJhY2ItMDQyNDA3ZGE2NTZmIiwiZW1haWwiOiJhZGFtLmxlY2hub3NAZ21haWwuY29tIn0.veWBGSGEUL8Gz9zHLHa0oWm6L_w3Y76-GtXG_oYnDrmgVAHU7e2RYCE7YEYRN2Mh1sZVLEXZdbQIgO-BNjQqbfLQwIeyDz4o0hAakUMYwuBvk1f9WfntTuszCS8jCZvK2ERZ8r9utcpKndjqVWt2RzGmYaSgJXa5xdCZXfSS77y3KhRvLKY-4AI-pnuthheRHFUzxZHkDhM0YXjL3lKSpjI3697bDBa5K-qRMTVNO37uVAno_AUJ1bb0C7iqwWAC0DN9D6QyGetY0coh4ex9IxmoHiti7D9pZKAyriufa5P6VAk-QNJpPWJ1b0rkT4dIZ_4vG2Ydh63hvUPN99NO_g","access_token":"eyJraWQiOiIyRDRPSlk2ZTY4OGt0aU94eXBSNWRvWEtEc3lHYmFCR01WWmJmYm1oN0dvPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJkNDg4ZTQzOC1iMGQxLTcwMTEtYmMyYy02MDRhMTk5ZmNkZDUiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbnMiXSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tXC91cy1lYXN0LTFfOGo2UjZqS0NZIiwidmVyc2lvbiI6MiwiY2xpZW50X2lkIjoiNWo5NzAxZW83cW1oZjkxb3RoNWVrczZraWkiLCJvcmlnaW5fanRpIjoiNjIwYTAxNjYtNGE0Yi00MDQ3LWI0ZDMtYWY3ZTkxYTU1NDQ3IiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJhd3MuY29nbml0by5zaWduaW4udXNlci5hZG1pbiBvcGVuaWQgdXNlcnNcL3JlYWQiLCJhdXRoX3RpbWUiOjE3MDg2MzE5ODQsImV4cCI6MTcwODYzNTU4NCwiaWF0IjoxNzA4NjMxOTg1LCJqdGkiOiI1YjI1YTRhYS0zZGZjLTRiZWUtOGIyMS0zMjA4NTRlY2QyOGUiLCJ1c2VybmFtZSI6ImFsZWNobm9zIn0.EWCEwDk46i8fOU4IVnlwgM7XNz_i-jtYcpyOYE8q4YGFC7giK5lWgzgIcD9_zHzUF6bVc6iv1uqtQDEXZlOU7pofMhUWBykqnDUC0Q57X4bP3giDigIYmfj77zJLxlWhwRvim28hZfJg9Sz_RIBcf13lo4D8bZvTE5HVEEI-tztuA4B-1dDY65po2zMHqwBEWF9FYaQC2edm5lyQEtTFleHVawBVbQWIU3Ud16TznAy9WEp2q_QgsNSFKuF-2LnQuO27MfyFWFGza8gDMrBwxVJ1l9bjrJuLH300QqQWLdaX7FTupOZHtvUxeND3K4Hc0-ZTu-nvpGUYOAxemfyyIQ","refresh_token":"eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.RMAy1jPNXxpGdPIr1TUukG685KbV5JgokWkBtnWDFOOlcFSRGWS-uNkglPdJJv4g1r4nk7jxYY8J8HnYmomzlt7OD0FdSnvrCEr61SbDZz5FZ9jhzdl-p2_fEoi_fUydpwG_JUliFucvutwDcBd1W2Ul900b24m1nHSrq_NL8r9uFJcVrkFDWLKQ9fxipSYZyU37LePN-qrxX78pQS2vIIe8tVvrG6CuK4GjdRDUvz10tpDFHdTFH75Bn0GHr5xoXXCuTg7CkuyipVYapYeI_AwJIEYBfLzlUjl99hrfkxDUVqlpyqgj9Jq_NOsXwt-sd73ZbPoBGAurAIw2Yw6mxg.WUaX_U7nlacSnml-.CctUJfNf4hngQr4QktmuTWTT5myYN03GzwVWgktiQpGHccW5jgK9QSQmKIG5v33qHoG5KOpm7xyKU9YsehJjpZHj8yq_NMMEamk7DCv4UR7ooXBJS2Hf6KL7Y-2sFxD6Eec7P37t1HtP5QOB1P5CNZgxW069hQpKj6uyOmOqvrso88Jtk18HjRw0SZY1r2jzdey-PRsoinukv2_JWaH2A35QFuApVwurov3DWl7kNKXkQldOROkYC1xrOidXxVTfirschCxSTcNWf481Jh9BF-W_eYcnyAJU0RAFQjZdLEdEUBTl2uH3jTVfGl9qdq32oXmd_EoeugBCW2zUbgekJbRlfmMWt42bZ67qz6ZAZ-cgijp16g1f01pXKV-vKdXIvjOm6IZin9whMwoK4i6zFjfAZLlYPRP2N-lZCRW8d7YeOz7S00OISy5qHF6DpDhm6sWFe0VBmyaYjZKzZob99DXyXBVLJukn1_R2MD5nJNRzCUvJCni3RZ4vEOW8lUK2RwcGjPiLgMH9EalVcALsIq0zV_SsSHUzgXeuvFz6sP-ygIkogrfLKGnGg5ssMpsL6rAlmSskz39veMmWDRxzx20daQXr_vpRHVmk5_Lg6alX7l3uMNGUOpvLEJssRsDWf99kuyXYWA0aqNr80RiJS67TXX0DrmhKtipvnd_cb3G5xcvVsu5xc37g9UnA57Bzvi1ulB9XlcgfrpKZxgPUTV0OtWvVvUDIoi06aOCOMeQgcMBRKoS6T8Qrplg8OzCGmg5cNPgap8foPfD9qgY5DWDlMgtmtohmH_Sg8dFTAdE0fmWhFXmWw5ErVlg4Ea0FtOl5ix8DqOQx0hT_ClhGW-aiXUHoVy7uZHK2Fa385aBoxrk-DtxO5r0ROUjnVwGTVUdUPBFWAb905nTs1K5cvWgkwdRp-wq4NFhwcDy8T1h5Dss3kouIx53JiZv5E4gsroynF7fOL_4vxlt0dM-ykWBB1sN988cTvqUNunWM3vofNWnaEg-_YP7xbOFas78HKqqm4-2UNlM0bYY8E8D6TDf9KtPbZb0Pt2HuJYv6z9JiAmS24Og7Bce1DiEOlGafLrSMgkHp84TumRXWOLurJtVIW2MajM06k3xvAQYdP4rcb4zgss_Pegtq-6AWgNpJ7TvT14NLjm2GXahu2x6gr4EG8Tr3LRDJwOAkxxNwogv2RfBqI8YrjQzDZ_-jzwhhdOvvik3FswYoeLv-UGy333K4gYYEu9SuPsvV5ag.Uy9EJjNpUCosi7jYTiIdew","expires_in":3600,"token_type":"Bearer"}
```

JWT.io deencoded Access Token
```
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

* For Implicit grants, the ID and Access Tokens are returned directly within the URL.